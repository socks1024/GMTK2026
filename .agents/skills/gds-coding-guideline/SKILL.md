---
name: gds-coding-guideline
description: GDScript 编码规范与代码风格指南。在编写或修改 GDScript 代码时使用此 skill。
---

# GDScript 编码规范

## 一、语法规范

### 1.1 类型标注
- **禁止 `:=` 自动推断**，变量和函数返回值**必须显式标注类型**
  - ✅ `var count: int = 0`
  - ✅ `func get_name() -> String:`
  - ❌ `var count := 0`
  - ❌ `func get_name():`
- 不要同时使用 `:=` 和类型标注（冗余标注）
  - ❌ `var key: String := "hello"`

### 1.2 注释
- 注释使用**中文**

### 1.3 日志
- 使用 **clog** 插件，不用 `print` / `push_warning` / `push_error`

---

## 二、代码顺序

按以下顺序组织代码：

```
1.  @tool, @icon, @static_unload
2.  class_name
3.  extends
4.  ## doc comment
5.  signals
6.  enums
7.  constants
8.  static variables
9.  @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
    1. _init()
    2. _enter_tree()
    3. _ready()
    4. _process()
    5. _physics_process()
    6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. inner classes
```

### 2.1 访问修饰符顺序
- 先 `public`，后 `private`

### 2.2 设计原则
1. 先写信号和属性，然后再写方法
2. 先写公共成员，然后再写私有成员
3. 先写虚函数回调，然后再写类的接口
4. 先写对象的构造函数和初始化函数 `_init` 和 `_ready`，然后再写运行时修改对象的函数

### 2.3 类声明
- 如果代码要在编辑器中运行，请将 `@tool` 注解写在脚本的第一行
- 然后是可选的 `@icon`，然后是 `class_name`
- 如果类是抽象类，在 `class_name` 前加 `@abstract`
- 然后是 `extends`
- 然后是文档注释

示例：
```gdscript
@tool
class_name MyNode
extends Node
## 类的简要描述。
##
## 脚本的详细描述，它能做什么，
## 以及更多细节。
```

### 2.4 内部类
采用单行形式声明：
```gdscript
## 内部类的简要描述。
@abstract class MyNode extends Node:
    pass
```

### 2.5 信号和属性声明顺序
信号 → 枚举 → 常量 → `@export` 变量 → 公共变量 → 私有变量 → `@onready` 变量

### 2.6 方法和静态函数顺序
从 `_init()` 开始，然后是 `_ready()`，接着是其他内置虚回调，最后是公共/私有方法：

```gdscript
func _init() -> void:
    add_to_group("state_machine")

func _ready() -> void:
    state_changed.connect(_on_state_changed)
    _state.enter()

func _unhandled_input(event: InputEvent) -> void:
    _state.unhandled_input(event)

func transition_to(target_state_path: String, msg: Dictionary = {}) -> void:
    if not has_node(target_state_path):
        return
    var target_state: Node = get_node(target_state_path)
    assert(target_state.is_composite == false)
    _state.exit()
    self._state = target_state
    _state.enter(msg)
    Events.player_state_changed.emit(_state.name)

func _on_state_changed(previous: String, new: String) -> void:
    print("state changed")
    state_changed.emit()