extends Control
## 滚动文本组件
##
## 在裁剪区域内持续滚动显示随机文本。
## 动态创建足够多的 Label 填满可视区域，滚出左侧后回收到右侧继续使用。

@export var text_pool: Array[String] = []

## 文本间距（像素）
@export var text_gap: float = 120.0
## 滚动速度（像素/秒）
@export var text_speed: float = 80.0
## Label 使用的字体设置（在场景中配置）
@export var label_settings: LabelSettings
## Label 字体大小
@export var font_size: int = 13

## 活跃的 Label 列表，按从左到右排列
var _labels: Array[Label] = []
## 上一条文本索引（避免连续重复）
var _last_index: int = -1
## 是否已初始化
var _initialized: bool = false


func _ready() -> void:
	# 等一帧让布局生效
	await get_tree().process_frame
	_initialize_labels()
	_initialized = true


func _process(delta: float) -> void:
	if not _initialized:
		return
	var move: float = text_speed * delta
	# 所有 Label 同步左移
	for lbl: Label in _labels:
		lbl.position.x -= move
	# 检查最左侧的 Label 是否已完全滚出
	_recycle_offscreen_labels()
	# 检查右侧是否需要补充新 Label
	_fill_right_side()


## 初始化：创建足够多的 Label 填满容器
func _initialize_labels() -> void:
	var clip_w: float = size.x
	var next_x: float = clip_w  # 从容器右侧开始排列
	# 持续创建直到填满 "容器宽度 + 一个屏幕" 的范围
	while next_x < clip_w * 2.0:
		var lbl: Label = _create_label()
		lbl.position.x = next_x
		next_x = lbl.position.x + lbl.size.x + text_gap
		_labels.append(lbl)


## 回收已滚出左侧的 Label
func _recycle_offscreen_labels() -> void:
	while _labels.size() > 0:
		var first: Label = _labels[0]
		if first.position.x + first.size.x > 0.0:
			break
		# 已完全滚出左侧，移除并回收
		_labels.remove_at(0)
		first.queue_free()


## 在右侧补充 Label，确保无缝
func _fill_right_side() -> void:
	var clip_w: float = size.x
	# 找到当前最右侧的边缘
	var right_edge: float = 0.0
	if _labels.size() > 0:
		var last: Label = _labels[_labels.size() - 1]
		right_edge = last.position.x + last.size.x + text_gap
	# 如果右侧边缘还在可视区域内，就需要补充
	while right_edge < clip_w + text_gap:
		var lbl: Label = _create_label()
		lbl.position.x = right_edge
		right_edge = lbl.position.x + lbl.size.x + text_gap
		_labels.append(lbl)


## 创建一个新的 Label 节点
func _create_label() -> Label:
	var lbl: Label = Label.new()
	lbl.text = _pick_random_text()
	lbl.add_theme_font_size_override("font_size", font_size)
	if label_settings != null:
		lbl.label_settings = label_settings
	add_child(lbl)
	# 立即计算尺寸
	lbl.size = lbl.get_minimum_size()
	# 纵向居中
	lbl.position.y = (size.y - lbl.size.y) / 2.0
	return lbl


## 随机选一条不重复的文本
func _pick_random_text() -> String:
	# 如果文本池为空，返回空字符串避免除零错误
	if text_pool.size() == 0:
		return ""
	var idx: int = randi() % text_pool.size()
	if text_pool.size() > 1:
		while idx == _last_index:
			idx = randi() % text_pool.size()
	_last_index = idx
	return text_pool[idx]
