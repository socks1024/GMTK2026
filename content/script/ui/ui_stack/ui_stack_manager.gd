extends Node
## UI 栈管理器。作为 AutoLoad 场景注册，管理多个 UI 栈层。
## 提供 push/pop 等 API，并统一处理 ui_cancel 返回操作。
##
## 在项目设置中注册为 AutoLoad（名称 UIStackManager），场景中静态配置各层。
## 事件优先级由各 UIStackLayer 的 layer 属性值决定，无需额外配置。
## 注意：AutoLoad 节点不需要 class_name，通过 AutoLoad 名称全局访问即可。

## 各层的栈，通过字符串 ID 标识。
## 在 _ready 中自动收集所有 UIStackLayer 子节点，以其 layer_id 作为 key。
var layers: Dictionary[String, UIStackLayer] = {}

## 任意层的栈发生变化时发出
signal layer_changed(layer_id: String)


func _ready() -> void:
	# 暂停时仍然处理输入（UI 需要在暂停时响应）
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 自动收集所有 UIStackLayer 子节点
	for child: Node in get_children():
		var stack_layer: UIStackLayer = child as UIStackLayer
		if stack_layer == null:
			continue
		var id: String = stack_layer.layer_id
		layers[id] = stack_layer
		stack_layer.stack_changed.connect(
			func() -> void: layer_changed.emit(id)
		)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# 只在栈中有内容时才拦截事件
		var stack_layer: UIStackLayer = _get_top_non_empty_layer()
		if stack_layer == null:
			return
		var top_control: StackableControl = stack_layer.peek()
		if top_control != null and top_control.back_action_enabled:
			stack_layer.pop_control()
			get_viewport().set_input_as_handled()


# ========== 公共 API ==========


## 将控件推入指定层的栈顶
func push(control: StackableControl, layer_id: String = "menu") -> void:
	var stack_layer: UIStackLayer = layers[layer_id]
	stack_layer.push_control(control)


## 弹出指定层的栈顶控件。如果不指定层，则弹出最高 layer 值非空层的栈顶。
func pop(layer_id: String = "") -> StackableControl:
	var stack_layer: UIStackLayer = _get_target_layer(layer_id)
	if stack_layer == null:
		return null
	return stack_layer.pop_control()


## 弹出到指定控件（在其所在层中）
func pop_to(target: StackableControl, layer_id: String = "menu") -> void:
	var stack_layer: UIStackLayer = layers[layer_id]
	stack_layer.pop_to(target)


## 清空指定层
func clear_layer(layer_id: String) -> void:
	var stack_layer: UIStackLayer = layers[layer_id]
	stack_layer.clear()


## 清空所有层
func clear_all() -> void:
	for layer_id: String in layers:
		layers[layer_id].clear()


## 获取指定层的栈顶控件
func peek(layer_id: String = "menu") -> StackableControl:
	var stack_layer: UIStackLayer = layers[layer_id]
	return stack_layer.peek()


## 获取当前最高 layer 值非空层的栈顶控件
func get_active_control() -> StackableControl:
	var stack_layer: UIStackLayer = _get_top_non_empty_layer()
	if stack_layer == null:
		return null
	return stack_layer.peek()


# ========== 内部方法 ==========


## 获取最高 layer 值的非空层。
## layer 值越大，渲染越靠前，事件优先级越高。
func _get_top_non_empty_layer() -> UIStackLayer:
	var best_layer: UIStackLayer = null
	var best_layer_value: int = -1
	for layer_id: String in layers:
		var stack_layer: UIStackLayer = layers[layer_id]
		if stack_layer.is_empty():
			continue
		if stack_layer.layer > best_layer_value:
			best_layer_value = stack_layer.layer
			best_layer = stack_layer
	return best_layer


## 获取目标层：如果指定了层 ID 则返回该层，否则返回最高 layer 值非空层
func _get_target_layer(layer_id: String) -> UIStackLayer:
	if layer_id != "":
		return layers[layer_id]
	return _get_top_non_empty_layer()
