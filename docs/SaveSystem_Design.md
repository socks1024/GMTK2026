# 存档系统设计方案

> 版本：v1.0（已落地）
> 状态：**已实现并通过测试场景验证**
> 目标：为项目模板提供一套"低耦合、低模板代码、强类型"的存档系统。
> 核心诉求：业务方**只需声明一个变量**，读写该变量即自动完成序列化与反序列化，不再需要手写 save/load 方法。

---

## 一、背景与目标

### 1.1 问题由来

传统做法（"集中式 SaveGame 对象 + 每个系统实现 `save()/load()`"）存在两个痛点：

1. **耦合严重**：存档类要"知道"所有系统；系统之间通过存档类互相污染。
2. **样板代码多**：每个系统都要手写一遍 `save_to_dict()` / `load_from_dict()`，字段一改三处。

我们的目标是：

> 把"存档"从一个**主动推数据给需求方**的模块，转变成一个**被动被需求方访问**的数据层。
> 业务方声明变量即可，存取过程对业务代码透明。

### 1.2 设计原则

- **数据即存档**：存档不是一次快照，而是一份"活着的" KV 存储；访问者随时读写。
- **强类型优先**：每种类型一个包装子类，避免 Variant 调用方反复类型转换。
- **渐进可用**：现有基于 `ConfigServer` 的用户设置代码无需推翻，两者分层独立。
- **模板最小化**：模板只提供最小底层能力，上层封装（存档菜单 UI、自动存档策略等）留给消费方按需派生。

---

## 二、方案概览

整体分为三层：

```
┌──────────────────────────────────────────────┐
│  业务层：PlayerManager / InventoryManager …  │
│  ↓ 声明字段即可                               │
├──────────────────────────────────────────────┤
│  包装层：AutoSerializeInt / Bool / Vector2 … │
│  （读写自动穿透到 SaveServer，                │
│   读档时自动刷新缓存并发 value_changed）      │
├──────────────────────────────────────────────┤
│  存储层：SaveServer（autoload 单例）          │
│  （磁盘 I/O、槽位管理、元信息、loaded 信号）  │
└──────────────────────────────────────────────┘
```

---

## 三、存储层：`SaveServer`

与 `ConfigServer` 定位不同：`ConfigServer` 管理用户设置（分辨率、音量等），`SaveServer` 管理游戏存档数据（玩家数据、关卡进度等），支持多槽位。已落地：[save_server.gd](/content/script/file/save_load/save_server.gd)。

### 3.1 形态

**autoload 单例**（`extends Node`），在 `project.godot` 中注册。选择 Node 形态的原因：需要定义 `signal loaded` 来驱动包装层的缓存失效（GDScript 静态类不支持 `signal`）。

### 3.2 实际 API

```gdscript
extends Node
## 游戏存档的 KV 存取层（autoload 单例）

## 存档加载完成后触发（读档路径）
signal loaded

## 存档文件扩展名
const SAVE_EXT: String = ".save"
## 元信息在 ConfigFile 中的专用段名/键名
const META_SECTION: String = "SaveMeta"
const META_KEY: String = "SaveMeta"

## 存档目录（首次访问懒创建 user://saves/）
var save_dir: String

## 当前已加载的槽位标识（运行时状态，不持久化）
var current_slot_id: String = ""
## 本次运行内的加载次数（运行时状态，不持久化）
var load_count: int = 0

# --- KV 读写（与 ConfigServer 对齐） ---

## 是否存在 section.key（未加载任何存档时返回 false）
func has_value(section: String, key: String) -> bool

## 读取（带默认值），类型由调用方保证
func get_value(section: String, key: String, default: Variant = null) -> Variant

## 写入内存中的存档对象（不立即刷盘；未加载任何存档时静默忽略）
func set_value(section: String, key: String, value: Variant) -> void

## 从内存中的存档对象删除某个键（不立即刷盘）
func erase_value(section: String, key: String) -> void

# --- 槽位管理 ---

## 创建新存档并立即落盘（slot_id 已存在则忽略；display_name 会写入 SaveMeta）
## 注意：创建后并不会自动加载，需要显式调用 load_from_slot 才会成为当前存档
func create_new_save(slot_id: String, display_name: String = "") -> void

## 从磁盘加载指定槽位的存档到内存，并发射 loaded 信号
func load_from_slot(slot_id: String) -> void

## 将内存中的存档对象写入磁盘的指定槽位（不存在会新建，存在会覆盖）
## 可用于"另存为"：即使 slot_id ≠ current_slot_id 也能写入
func save_to_slot(slot_id: String) -> void

## 将内存中的存档对象写回当前加载的槽位（save_to_slot 的语法糖）
func save_to_curr_slot() -> void

## 只读取指定槽位的元信息，不加载 KV，也不污染 _cached_save（存档列表页用）
func peek_meta(slot_id: String) -> SaveMeta

## 删除指定槽位的存档文件
func delete_slot(slot_id: String) -> void

## 列出存档目录下所有的槽位标识（按文件名字典序）
func list_slots() -> PackedStringArray
```

> **slot_id** 是调用方生成的槽位标识字符串（如 `"manual_0"`、`"auto"`、`"quick"`），同时也作为存档文件名（加上 `SAVE_EXT` 后缀）。
>
> **新建 ≠ 加载**：`create_new_save` 只建文件；要让它成为当前存档必须再调 `load_from_slot`。
>
> **另存为**：`save_to_slot(其他槽位)` 天然支持，写完后 `current_slot_id` 不变；如需后续"当前存档"也跟着切，业务层自行更新 `SaveServer.current_slot_id`。
>
> **没有自动 flush**：刷盘时机完全由调用方掌握（手动保存按钮、章节切换、退出前等）。

### 3.3 存储格式

- **默认**：`ConfigFile`（与 `ConfigServer` 一致，开发期友好，人肉可读）。
- `SaveMeta` 与业务 KV 一起存在同一个 `ConfigFile` 中，占用专用的 `META_SECTION` / `META_KEY` 段，避免与业务段冲突。
- 格式封装在 `SaveServer` 内部，业务层感知不到。未来切成二进制或 JSON 不影响上层。

---

## 四、包装层：`AutoSerializeVar` 家族

核心思想：**一个类型一个包装类**，业务方声明字段即可，读写自动穿透 `SaveServer`；读档时由 `SaveServer.loaded` 信号驱动缓存刷新。

### 4.1 基类

实际实现见 [auto_serialize_var.gd](/content/script/file/save_load/auto_serialize_var.gd)：

```gdscript
@abstract class_name AutoSerializeVar extends RefCounted
## 自动序列化字段的基类（抽象类，不直接使用）

## 当前值发生变化时触发（包括读档导致的值变化）
signal value_changed(new_value: Variant)

var _section: String
var _key: String
var _default: Variant
var _cache: Variant
var _dispose_signal: Signal        # 宿主销毁信号，触发后自动断开订阅

func _init(section: String, key: String, default: Variant, dispose_signal: Signal) -> void:
	_section = section
	_key = key
	_default = default
	_dispose_signal = dispose_signal

	# 构造即读一次：如果此时已有存档加载，直接读真实值；否则先记 default
	_cache = SaveServer.get_value(_section, _key, _default) if SaveServer._cached_save != null else _default

	SaveServer.loaded.connect(_on_save_loaded)
	_dispose_signal.connect(_dispose)

## 存档加载完成时刷新缓存，值有变化则抛出 value_changed
func _on_save_loaded() -> void:
	var new_value: Variant = SaveServer.get_value(_section, _key, _default)
	if new_value == _cache:
		return
	_cache = new_value
	value_changed.emit(_cache)

## 宿主销毁时断开所有信号连接，防止泄漏
func _dispose() -> void:
	if SaveServer.loaded.is_connected(_on_save_loaded):
		SaveServer.loaded.disconnect(_on_save_loaded)
	if _dispose_signal.is_connected(_dispose):
		_dispose_signal.disconnect(_dispose)
```

### 4.2 具体类型子类

每个子类只负责暴露一个强类型的 `value` 属性，get/set 做缓存与穿透：

```gdscript
class_name AutoSerializeString extends AutoSerializeVar

func _init(section: String, key: String, default: String, dispose_signal: Signal) -> void:
	super._init(section, key, default, dispose_signal)

var value: String:
	get():
		return _cache
	set(v):
		if _cache == v:
			return
		_cache = v
		SaveServer.set_value(_section, _key, v)
		value_changed.emit(v)
```

已落地的子类（均在 [content/script/file/save_load/auto_serialize_vars/](/content/script/file/save_load/auto_serialize_vars/)）：

| 类名 | 承载类型 |
|---|---|
| `AutoSerializeInt` | `int` |
| `AutoSerializeBool` | `bool` |
| `AutoSerializeFloat` | `float` |
| `AutoSerializeString` | `String` |
| `AutoSerializeVector2` | `Vector2` |
| `AutoSerializeColor` | `Color` |

需要新类型时，照着 [auto_serialize_string.gd](/content/script/file/save_load/auto_serialize_vars/auto_serialize_string.gd) 复制一份改类型即可，十来行代码。

### 4.3 使用示例

```gdscript
extends Node
class_name PlayerManager

const SAVE_SECTION: String = "Player"

@export var default_hp: int = 100     # 默认值通过 @export 暴露给 Inspector
@export var default_gold: int = 0

var hp: AutoSerializeInt
var gold: AutoSerializeInt
var alive: AutoSerializeBool
var pos: AutoSerializeVector2

func _ready() -> void:
	hp = AutoSerializeInt.new(SAVE_SECTION, "hp", default_hp, tree_exiting)
	gold = AutoSerializeInt.new(SAVE_SECTION, "gold", default_gold, tree_exiting)
	alive = AutoSerializeBool.new(SAVE_SECTION, "alive", true, tree_exiting)
	pos = AutoSerializeVector2.new(SAVE_SECTION, "pos", Vector2.ZERO, tree_exiting)

	# UI 刷新只需监听 value_changed，读档时会自动触发
	hp.value_changed.connect(_refresh_hp_bar)

func take_damage(dmg: int) -> void:
	hp.value -= dmg
	if hp.value <= 0:
		alive.value = false
```

业务方**不用写任何 save/load 方法**，也不用知道存档文件在哪儿。

---

## 五、读档流程

1. 调用方 `SaveServer.load_from_slot(slot_id)`
2. `SaveServer` 从磁盘读 `ConfigFile` 填充 `_cached_save`，提取 `_cached_save_meta`，`load_count += 1`
3. `SaveServer` 发射 `loaded` 信号
4. 每个活着的 `AutoSerializeVar` 在 `_on_save_loaded` 里重新 `get_value`，若值变化则自己发 `value_changed`
5. 订阅了 `value_changed` 的业务/UI 自动刷新

**为什么选信号驱动而不是"加载计数器对比"**：

- 信号驱动的 `value_changed` 能直接联动 UI，少一层手写刷新代码
- 订阅 + 宿主 `dispose_signal` 的组合能自动断开，宿主销毁后包装对象可被 `RefCounted` 回收，零泄漏
- 代价是每个 `AutoSerializeVar` 都会连接 `SaveServer.loaded`，读档时按订阅数量发一次；规模可控

---

## 六、存档元信息：`SaveMeta`

业务数据（KV）之外，每份存档还有一些**描述自身的信息**，用于存档列表展示、版本校验等。统一放在 `SaveMeta` 里，与 KV 一起持久化到存档文件。

### 6.1 字段定义

实际实现见 [save_meta.gd](/content/script/file/save_load/save_meta.gd)：

```gdscript
class_name SaveMeta extends Resource
## 存档的元信息（每份存档一份，随 KV 一起持久化）

@export var created_time: int = 0          # 首次创建时间戳（Unix 秒）
@export var modified_time: int = 0         # 最近一次保存的时间戳（Unix 秒）
@export var saved_count: int = 0           # 已保存次数
@export var play_time_seconds: int = 0     # 累计"从创建到最近一次保存"的秒数
@export var game_version: String = ""      # 保存时的游戏版本号
@export var display_name: String = ""      # 玩家可见名称

## 首次创建存档时调用
func initialize(name: String) -> void:
	self.display_name = name
	self.created_time = int(Time.get_unix_time_from_system())
	update()

## 每次保存前调用，集中更新随保存变化的字段
func update() -> void:
	self.saved_count += 1
	self.modified_time = int(Time.get_unix_time_from_system())
	self.game_version = ProjectSettings.get_setting("application/config/version", "")
	self.play_time_seconds = modified_time - self.created_time
```

> 槽位标识不放进 `SaveMeta`：`slot_id` 即文件名，文件名即身份。
>
> `SaveMeta` 自身负责 `saved_count` / `modified_time` / `game_version` 的更新逻辑，`SaveServer.save_to_slot` 只调用一次 `update()`，不直接碰字段。
>
> 字段按需增删；模板提供最小够用集合，项目可派生 `SaveMeta` 子类补充（如 `schema_version`、`description`、`thumbnail` 等）。

### 6.2 在 `SaveServer` 里的位置

`SaveServer` 把 `SaveMeta` 直接放进承载 KV 的 `ConfigFile` 里（专用段 `META_SECTION`/`META_KEY`），不单独用公共字段暴露，而是以 `_cached_save_meta` 持有一份缓存，在 `save_to_slot` 时写回：

```gdscript
func save_to_slot(slot_id: String) -> void:
	_cached_save_meta.update()
	_cached_save.set_value(META_SECTION, META_KEY, _cached_save_meta)
	_cached_save.save(_get_save_path(slot_id))
```

### 6.3 用途

| 字段 | 用途 |
|---|---|
| `saved_count` | UI 上显示"已保存 N 次" |
| `created_time` | 存档列表展示"创建于 X" |
| `modified_time` | 存档列表排序、展示"最近保存于 X" |
| `play_time_seconds` | 存档列表展示"游戏时长" |
| `game_version` | 读档时若与当前版本差异过大，提示玩家"存档来自旧版" |
| `display_name` | UI 列表里给玩家看的存档名 |

### 6.4 存档列表页的优化

存档列表页只需要 `SaveMeta`，不需要加载整份 KV。`SaveServer.peek_meta(slot_id)` 会临时开一个 `ConfigFile` 读取并只取出 meta 段，**不修改** `_cached_save`、也**不发射** `loaded`、也**不动** `load_count`。列表页可以随便调用，不会影响玩家当前存档。

> 进一步的物理布局优化（例如把 meta 放到文件头部二进制区、KV 放后半段）可以按需再加；基于 `ConfigFile` 当前已能满足功能。

---

## 七、测试场景

已提供测试场景 [save_load_test.tscn](/test/save_load_test.tscn) / [save_load_test.gd](/test/save_load_test.gd)，覆盖了：

- 三个存档槽位卡片（通过 `peek_meta` 渲染）
- 新建 / 读档 / 保存 / 删除四个按钮
- 用 `AutoSerializeInt` / `AutoSerializeString` 展示"已加载存档的实时数据"
- "当前内存编辑值"与"落盘后数据"两个面板对比，验证 `set_value` 不立即刷盘、`save_to_*` 后才落盘
- 未加载任何存档时，"已加载存档"面板自动隐藏

是移植到业务项目时的最佳参考实现。

---

## 八、使用守则（踩坑提示）

1. **先加载，再操作**：未加载任何存档时 `SaveServer._cached_save == null`，`set_value` 会静默忽略，`get_value` 会返回默认值。业务场景进入前务必 `load_from_slot`。
2. **新建 ≠ 加载**：`create_new_save` 只建文件；要让它成为当前存档必须再调 `load_from_slot`。
3. **`dispose_signal` 必须传**：否则节点销毁后 `SaveServer.loaded` 仍持有回调引用，下次读档时崩。推荐统一传 `tree_exiting`（Node 宿主）或其他能代表"对象生命周期结束"的信号。
4. **存档列表页用 `peek_meta`**：绝不能用 `load_from_slot` 去枚举所有槽位，那会把玩家当前存档覆盖掉。
5. **另存为**：直接 `save_to_slot(目标槽位)` 即可；如需后续"当前存档"也跟着切，业务层自行更新 `SaveServer.current_slot_id`。

---

## 九、已知取舍

| 项 | 说明 | 态度 |
|---|---|---|
| 必须写 `.value` | GDScript 无运算符重载，`hp.value -= 1` 无法简化 | 接受 |
| 包装对象本身不能 `@export` | `RefCounted` 不可 Inspector 化；默认值通过独立 `@export var default_xxx` 传入构造参数 | 接受 |
| section/key 字符串手写 | 同一系统用 `const SECTION` 统一、key 与变量名保持一致即可 | 接受 |
| 每类型一个子类 | 十来行重复代码，可接受；按需扩展 | 接受 |
| 读档时会逐个 `AutoSerializeVar` 拉一次值 | 规模可控，订阅对象随宿主销毁自动释放；若出现大规模性能问题再优化 | 暂缓 |
