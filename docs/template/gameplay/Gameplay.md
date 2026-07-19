# Gameplay 游戏玩法

## 网格关卡编辑器

### 2D 网格系统

**路径：** `content/script/gameplay/grid_system/`

**文件：** `grid_system_2d.gd`、`grid_entity_2d.gd`

**说明：** 通用的无限 2D 网格管理系统。以 Node2D 的 position 为原点，提供坐标转换、格子占用追踪、实体移动/阻挡/重叠检测等功能。网格无固定边界，可向任意方向延伸。配合 TileMapLayer 子节点（ZoneLayer + EntityLayer）实现地形数据查询和场景瓦片自动注册。

**核心功能：**
- **坐标转换** — `grid_to_world()` / `world_to_grid()`，网格坐标与世界坐标互转
- **占用追踪** — `place_entity()` / `remove_entity()` / `move_entity()`，O(1) 反向索引查表
- **碰撞系统** — 基于位掩码的 `grid_layer` / `block_mask` / `overlap_mask`，支持阻挡检测和重叠回调
- **多格实体** — `GridEntity2D.cell_size` 支持任意尺寸的实体占用
- **地形查询** — `get_cell_data()` / `get_cell_custom_data()` / `get_filtered_cells()`，读取 TileSet 的 Custom Data
- **编辑器工具** — `@tool` 模式下修改格子尺寸自动同步所有 TileMapLayer 的 TileSize

**信号：**
- `entity_placed` / `entity_removed` / `entity_moved` / `entity_blocked` / `entity_overlapped`

**GridEntity2D 虚方法（子类覆写）：**
- `_on_placed()` / `_on_removed()` / `_on_blocked()` / `_on_overlap()`

---

## 导表工具

### CSV 2 Resource

**路径：** `addons/data_importer/`

**文件：** `plugin.gd`（插件入口）、`csv_import_plugin.gd`（CSV 导入核心逻辑）

**说明：** 基于 `EditorImportPlugin`，将 CSV 表格自动导入为强类型 Resource（`.tres`）。数据在编辑器阶段转为 `.tres`，运行时零解析开销。Godot 内置会将 CSV 识别为 Translation，需在导入面板的"导入为"下拉菜单中手动选择 **Data Importer**。

**CSV 表格格式：** 前三行为表头，第四行起为数据：
- **第一行** — 字段注释（导入时忽略）
- **第二行** — 字段名称（对应 Resource 的变量名）
- **第三行** — 字段数据类型

```csv
编号,名称,血量,攻击力,速度,是否Boss
id,name,hp,atk,speed,is_boss
int,String,int,int,float,bool
1001,史莱姆,50,5,1.2,false
```

**支持的类型：**
- `int` / `float` / `String` / `bool`（`true`/`false`/`1`/`0`）
- `Array[String]` / `Array[int]` — JSON 格式，CSV 中需双引号包裹
- `Color` — `#ff0000` 或 `1.0,0.0,0.0,1.0`
- 类型省略时默认为 `String`

**导入选项：**

| 选项 | 说明 |
|---|---|
| `resource_script` | 单条数据的 Resource 脚本路径 |

**导入流程：**
1. 解析表头（第二行字段名、第三行类型）
2. 逐行解析数据，按类型标注转换值
3. 为每行创建 Resource 实例，保存为 `{表名}_{第一列值}.tres`

**使用流程：**
1. 启用插件：项目设置 → 插件 → 启用 "Data Importer"
2. 编写 Resource 脚本，`@export` 字段名与 CSV 表头一致，放在 `content/script/data/` 下
3. CSV 文件放入 `data/tables/` 目录
4. 编辑器中选中 CSV → 导入面板 → 设置 `resource_script` → 重新导入
5. 游戏中 `preload` / `load` 生成的 `.tres` 直接使用

**目录结构：**
```
data/tables/
├── monster.csv           # 源表格
├── monster_1001.tres     # 导入生成（自动）
├── monster_1002.tres
└── monster_1003.tres

content/script/data/
└── monster_data.gd       # 单条数据 Resource
```

**注意事项：**
- CSV 编码必须为 **UTF-8**
- Resource 脚本的 `@export` 字段名必须与 CSV 表头完全一致
- 修改 CSV 后需在编辑器中重新导入
- JSON 只能序列化基础类型，`Vector2` 等需拆分为基础字段
