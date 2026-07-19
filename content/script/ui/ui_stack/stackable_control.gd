@abstract class_name StackableControl
extends Control
## UI 栈管理系统的可栈管理控件基类。
## 所有需要被 UIStackManager 管理的 UI 控件都应继承此类。
## 提供统一的激活/反激活生命周期，子类只需重写 _on_activated / _on_deactivated / _on_removed。

## 该控件所属的层标识
@export var layer_id: String = "menu"
## 是否响应 ui_cancel 自动 pop（默认 true）
@export var back_action_enabled: bool = true
## 该控件被激活时自动获取焦点的控件
@export var focus_target: Control

## 控件进入栈顶时触发
signal activated
## 控件离开栈顶时触发
signal deactivated


## 由 UIStackLayer 调用。控件进入栈顶时执行。
## 基类负责启用输入并发射信号，子类通过 _on_activated 处理自身逻辑。
func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	focus_target.grab_focus()
	_on_activated()
	activated.emit()


## 由 UIStackLayer 调用。控件离开栈顶时执行。
## 基类负责禁用输入并发射信号，子类通过 _on_deactivated 处理自身逻辑。
## 注意：不会 hide，控件保持可见但不接收输入。
func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	_on_deactivated()
	deactivated.emit()


## 弹出关联 UIStackLayer 顶端的控件，通常用于返回到上一级界面。
func _pop_related_layer() -> void:
	UIStackManager.pop(layer_id)


## 由 UIStackLayer 调用。控件被 pop 移除时执行。
## 基类调用子类的 _on_removed 后不做额外处理，控件的销毁由子类决定。
func remove_from_stack() -> void:
	_on_removed()


## 子类重写：控件进入栈顶时的业务逻辑（如设置焦点、播放动画）。
## 首次 push 和上层 pop 后重新回到栈顶都会调用。
func _on_activated() -> void:
	pass


## 子类重写：控件离开栈顶时的业务逻辑（如保存状态、停止动画）。
func _on_deactivated() -> void:
	pass


## 子类重写：控件被 pop 移除时的清理逻辑。
## 默认实现为 queue_free()，如需复用控件请重写此方法。
func _on_removed() -> void:
	queue_free()
