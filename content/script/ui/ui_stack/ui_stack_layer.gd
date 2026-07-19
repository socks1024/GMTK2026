class_name UIStackLayer
extends CanvasLayer
## 单层 UI 栈。管理一组 StackableControl 的 push/pop 操作。
## 继承 CanvasLayer，通过 layer 属性控制渲染层级。
## layer 值越大，渲染越靠前，ui_cancel 事件优先级越高。

## 层的字符串标识，如 "menu"、"hud"、"popup"
@export var layer_id: String = ""

## 栈内容变化时发出（push/pop/clear 后）
signal stack_changed

## 栈数据
var _stack: Array[StackableControl] = []


## 将控件推入栈顶
func push_control(control: StackableControl) -> void:
	# 反激活当前栈顶
	if not _stack.is_empty():
		_stack.back().deactivate()
	# 压入新控件
	_stack.push_back(control)
	add_child(control)
	control.activate()
	stack_changed.emit()


## 弹出栈顶控件
func pop_control() -> StackableControl:
	if _stack.is_empty():
		return null
	var control: StackableControl = _stack.pop_back()
	control.deactivate()
	control.remove_from_stack()
	remove_child(control)
	# 恢复新栈顶
	if not _stack.is_empty():
		_stack.back().activate()
	stack_changed.emit()
	return control


## 弹出到指定控件（该控件保留在栈顶）
func pop_to(target: StackableControl) -> void:
	while _stack.size() > 1 and _stack.back() != target:
		var control: StackableControl = _stack.pop_back()
		control.deactivate()
		control.remove_from_stack()
		remove_child(control)
	# 恢复目标控件
	if not _stack.is_empty():
		_stack.back().activate()
	stack_changed.emit()


## 清空整个栈
func clear() -> void:
	while not _stack.is_empty():
		var control: StackableControl = _stack.pop_back()
		control.deactivate()
		control.remove_from_stack()
		remove_child(control)
	stack_changed.emit()


## 获取栈顶控件（不弹出）
func peek() -> StackableControl:
	if _stack.is_empty():
		return null
	return _stack.back()


## 栈是否为空
func is_empty() -> bool:
	return _stack.is_empty()


## 栈中控件数量
func size() -> int:
	return _stack.size()
