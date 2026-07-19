# UI 用户界面

TODO 需要优化

## 基本界面

模板提供了以下预制界面：

**开始游戏界面：** - `content/scene/ui/menus/start/`
- 游戏入口界面，包含开始游戏、设置、退出等按钮

**设置界面：** - `content/scene/ui/menus/settings/`
- 包含音频、视频、输入等设置选项卡
- 输入设置自动生成所有自定义动作的按键配置控件

**制作者名单界面：** - `content/scene/ui/menus/credit/`
- 显示游戏制作团队信息

## 通用 UI 组件

### Common Button

`CommonButton` 是一个带有按下动画和音效的增强按钮。

**核心属性：**

- `duration: float` - 动画持续时间
- `ease_curve: Curve` - 动画缓动曲线
- `press_sound: AudioEvent` - 按下时播放的音效

**核心信号：**

- `button_anim_finish` - 按钮动画播放完成时发出

### Common Texture Button

`CommonTextureButton` 继承自 `TextureButton`，在 `CommonButton` 的基础上追加了 Hover 反馈与 Disabled 变色的效果。

**核心属性：**

- `duration: float` - 按下缩放动画时长
- `ease_curve: Curve` - 按下缩放动画曲线
- `press_sound: AudioEvent` - 按下时播放的音效
- `hover_scale: float` - 鼠标悬停时的缩放倍率，设为 `1.0` 即可关闭悬停放大
- `hover_duration: float` - 悬停缩放动画时长
- `hover_sound: AudioEvent` - 鼠标悬停时播放的音效
- `auto_gray_when_disabled: bool` - 是否在 `disabled = true` 时自动将 `modulate` 置为灰色
- `disabled_modulate: Color` - 变灰时使用的颜色

**核心信号：**

- `button_anim_finish` - 按下动画播放完成时发出

**设计说明：**
- `disabled` 为 `true` 时不会触发 Hover 音效与放大。
- 若配置了 `texture_disabled` 贴图，可将 `auto_gray_when_disabled` 关闭，改由贴图本身表达 Disabled 状态。

### InputButton

`InputButton` 是一个输入捕获按钮，继承自 `CommonButton`，新增了捕获输入并显示在按钮上的功能。不会捕捉鼠标移动输入。

**核心属性：**

- `initial_text: String` - 初始显示文本
- `waiting_text: String` - 等待输入时显示的文本
- `catch_mouse_move: bool` - 是否捕获鼠标移动
- `joypad_motion_deadzone: float` - 手柄摇杆死区（0-1）
- `mouse_motion_deadzone: float` - 鼠标移动死区

**核心信号：**

- `input_catched(event: InputEvent)` - 捕获到输入时发出

### ConfigControl

`ConfigControl` 是配置控件的抽象基类。
加入场景树时，控件会加载默认值并显示。
用户修改控件时，新的值会被自动保存到配置，并发出 `config_changed` 信号。可以通过该类的派生类来创建具体的配置控件，如绑定音量的滑动条。

**核心属性：**

- `config_section: String` - 配置分类
- `config_key: String` - 配置项名称

**核心信号：**

- `config_changed(value)` - 配置更改时发出

**抽象方法：**

- `get_default_value() -> Variant` - 获取默认值
- `set_control_value(value: Variant)` - 更新控件显示的值
- `set_control_editable(editable: bool)` - 设置控件是否可编辑
- `connect_control_input()` - 连接控件的输入信号

## UI 栈管理系统

**路径：** `content/script/ui/ui_stack/`、`content/scene/ui/ui_stack_manager.tscn`

基于栈结构的 UI 导航管理系统，支持多层独立栈（menu / hud / popup），自动处理 `ui_cancel` 返回。作为 AutoLoad 场景注册，全局通过 `UIStackManager` 访问。

**默认层级配置：**

| 层 ID | CanvasLayer.layer | 用途 |
|---|---|---|
| `"hud"` | 126 | 游戏内 HUD |
| `"menu"` | 127 | 全屏/半屏菜单 |
| `"popup"` | 128 | 模态弹窗 |

### StackableControl — 可栈管理控件基类

**路径：** `content/script/ui/ui_stack/stackable_control.gd`

所有需要被栈管理的 UI 控件都应继承此基类。它定义了统一的生命周期回调，子类只需关注自身业务逻辑。

**核心属性：**

- `back_action_enabled: bool` - 是否响应 ui_cancel 自动 pop，默认 true

**核心信号：**

- `activated` - 控件进入栈顶时触发
- `deactivated` - 控件离开栈顶时触发

**抽象方法（子类重写）：**

- `_on_activated()` - 控件进入栈顶时的业务逻辑（如设置焦点、播放动画）。首次 push 和上层 pop 后重新回到栈顶都会调用
- `_on_deactivated()` - 控件离开栈顶时的业务逻辑（如保存状态、停止动画）。被新控件覆盖和被 pop 移除时都会调用
- `_on_removed()` - 控件被 pop 移除时的清理逻辑。默认实现为 `queue_free()`，如需复用控件请重写此方法

**设计说明：**
- `activate()` / `deactivate()` / `remove_from_stack()` 是公共方法，由 UIStackLayer 调用，子类不应直接调用
- `deactivate()` 只禁用 `process_mode`，不调用 `hide()`，控件保持可见实现视觉堆叠效果

### UIStackLayer — 单层栈

**路径：** `content/script/ui/ui_stack/ui_stack_layer.gd`

每个 UIStackLayer 管理一个独立的 UI 栈。继承自 `CanvasLayer`，通过 `layer` 属性控制渲染层级和事件优先级。

**核心属性：**

- `layer_id: String` - 层的字符串标识，如 "menu"、"hud"、"popup"

**核心信号：**

- `stack_changed` - 栈内容变化时发出（push/pop/clear 后）

**核心方法：**

- `push_control(control: StackableControl)` - 将控件推入栈顶
- `pop_control() -> StackableControl` - 弹出栈顶控件
- `pop_to(target: StackableControl)` - 弹出到指定控件（该控件保留在栈顶）
- `clear()` - 清空整个栈
- `peek() -> StackableControl` - 获取栈顶控件（不弹出）
- `is_empty() -> bool` - 栈是否为空
- `size() -> int` - 栈中控件数量

**设计说明：**
- 继承 CanvasLayer，layer 值越大渲染越靠前
- 控件作为 UIStackLayer 的子节点添加，自然堆叠显示

### UIStackManager — 栈管理器

**路径：** `content/script/ui/ui_stack/ui_stack_manager.gd`

管理所有 UIStackLayer，提供全局 API，处理 `ui_cancel` 自动返回。`res://content/scene/ui/ui_stack_manager.tscn` 作为 AutoLoad 场景注册，场景内包含基础 UIStackLayer，任何脚本可通过全局名称 `UIStackManager` 直接访问。

**核心属性：**

- `layers: Dictionary[String, UIStackLayer]` - 各层的栈，`_ready` 中自动收集所有 UIStackLayer 子节点

**核心信号：**

- `layer_changed(layer_id: String)` - 任意层的栈发生变化时发出

**核心方法：**

- `push(control: StackableControl, layer_id: String = "menu")` - 将控件推入指定层的栈顶
- `pop(layer_id: String = "") -> StackableControl` - 弹出指定层的栈顶控件。不指定层则弹出最高 layer 值非空层的栈顶
- `pop_to(target: StackableControl, layer_id: String = "menu")` - 弹出到指定控件
- `clear_layer(layer_id: String)` - 清空指定层
- `clear_all()` - 清空所有层
- `peek(layer_id: String = "menu") -> StackableControl` - 获取指定层的栈顶控件
- `get_active_control() -> StackableControl` - 获取当前最高 layer 值非空层的栈顶控件

**设计说明：**
- AutoLoad 场景注册（名称 `UIStackManager`），无需 class_name，通过全局名称直接访问
- 使用 `_input` 而非 `_unhandled_input` 处理 `ui_cancel`，因为 TabContainer 等 GUI 控件会在 GUI 阶段消耗该事件。栈为空或栈顶 `back_action_enabled = false` 时不消耗事件，让事件继续传播
- `process_mode = ALWAYS`，暂停时 UI 仍需响应输入
- 事件优先级由各 UIStackLayer 的 `layer` 属性值决定，无需额外配置

### 使用示例

```gdscript
# 打开设置菜单（默认推入 menu 层）
var settings: StackableControl = settings_scene.instantiate()
UIStackManager.push(settings)

# 从设置中打开子页面（堆叠在设置之上，设置仍然可见）
var sub_page: StackableControl = sub_page_scene.instantiate()
UIStackManager.push(sub_page)

# 按 ui_cancel 自动 pop 回设置（无需手动编写）

# 打开确认弹窗（在弹窗层）
var confirm: StackableControl = confirm_scene.instantiate()
UIStackManager.push(confirm, "popup")

# 按 ui_cancel 先关弹窗（popup 层 layer 最大），再按一次才回到设置
```

## 弹出菜单

**路径：** `content/scene/ui/menus/popup/`

`CommonPopup` 是一个多页翻页弹窗组件，支持滑入/滑出动画，适用于教程引导、公告展示等场景。

**核心属性：**

- `slide_offset: float` - 滑动偏移量（像素），默认 300.0
- `anim_duration: float` - 动画时长（秒），默认 0.6
- `slide_direction: SlideDirection` - 滑入滑出方向，支持 LEFT / RIGHT / UP / DOWN，默认 UP
- `slide_in_ease: Tween.EaseType` - 滑入缓动类型
- `slide_in_trans: Tween.TransitionType` - 滑入过渡类型
- `slide_out_ease: Tween.EaseType` - 滑出缓动类型
- `slide_out_trans: Tween.TransitionType` - 滑出过渡类型

**核心方法：**

- `show_pages(pages: Array[String], title: String, middle_text: String, finish_text: String)` - 显示弹窗，传入页面内容数组、标题、翻页按钮文本和完成按钮文本

**核心信号：**

- `popup_closed` - 弹窗关闭时发出（所有页面浏览完毕并播放完滑出动画后）

**使用方式：** 将 `common_popup.tscn` 实例化到场景中，调用 `show_pages()` 方法传入页面内容即可。内容支持 BBCode 富文本格式（使用 RichTextLabel 显示）。弹窗会自动处理翻页逻辑和关闭动画。

## UI 装饰组件

### ScrollingText 滚动文本

**路径：** `content/scene/ui/decoration/scrolling_text/`

`ScrollingText` 是一个在裁剪区域内持续滚动显示随机文本的装饰组件，适用于新闻滚动条、公告栏、氛围装饰等场景。

**核心属性：**

- `text_pool: Array[String]` - 文本池，滚动显示的文本内容列表
- `text_gap: float` - 文本间距（像素），默认 120.0
- `text_speed: float` - 滚动速度（像素/秒），默认 80.0
- `label_settings: LabelSettings` - Label 使用的字体设置（在场景中配置）
- `font_size: int` - 字体大小，默认 13

**工作原理：** 组件启动时从容器右侧开始动态创建 Label 节点填满可视区域。每帧所有 Label 同步向左移动，滚出左侧边界的 Label 会被回收释放，右侧空缺时自动补充新的 Label，实现无缝循环滚动效果。文本从 `text_pool` 中随机选取，且避免连续重复。

**使用方式：** 将 `scrolling_text.tscn` 实例化到场景中，在检查器面板中配置 `text_pool` 文本列表和滚动参数即可。组件根节点开启了 `clip_contents`，文本会被自动裁剪在控件范围内。