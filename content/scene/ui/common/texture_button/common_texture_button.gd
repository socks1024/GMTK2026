class_name CommonTextureButton extends TextureButton
## 通用贴图按钮
##
## 在 TextureButton 基础上扩展：
## 1. 按下时播放音效与缩放动画（类似 CommonButton）
## 2. Hover 时播放音效与轻微放大
## 3. Disabled 时自动变灰（可选）

signal button_anim_finish

# ===== 按下动画相关 =====
@export_group("Press")
## 按下缩放动画时长
@export var duration: float = 0.3
## 按下缩放动画曲线
@export var ease_curve: Curve
## 按下音效
@export var press_sound: AudioEvent

# ===== Hover 相关 =====
@export_group("Hover")
## 鼠标悬停时的缩放倍率
@export var hover_scale: float = 1.1
## 鼠标悬停时播放的音效
@export var hover_sound: AudioEvent
## 悬停缩放动画时长
@export var hover_duration: float = 0.1

# ===== Disabled 相关 =====
@export_group("Disabled")
## 是否在 disabled 时自动将 modulate 变灰
@export var auto_gray_when_disabled: bool = true
## 变灰时使用的颜色
@export var disabled_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)

var _press_tween: Tween
var _hover_tween: Tween
var _is_hovered: bool = false
var _normal_modulate: Color = Color.WHITE

func _ready() -> void:
	if ease_curve:
		ease_curve.bake()
	_normal_modulate = modulate
	_refresh_disabled_visual()
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# 监听 disabled 属性变化（Godot 没有内置信号，用 _process 变化检测过重，改为在常见入口刷新）
func _notification(what: int) -> void:
	# 通过主题相关通知触发刷新，disabled 改变时会触发 NOTIFICATION_THEME_CHANGED 与视觉更新
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_VISIBILITY_CHANGED:
		_refresh_disabled_visual()

func _on_button_pressed() -> void:
	# 按下动画进行中则不重复播放
	if _press_tween and _press_tween.is_running():
		return
	if press_sound:
		AudioManager.play_sound(press_sound)
	# 按下时打断 hover 动画，保证缩放一致
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
	scale = Vector2.ONE
	_press_tween = create_tween()
	_press_tween.tween_property(self, "scale", Vector2.ZERO, duration)\
		.set_custom_interpolator(TweenUtils.curve_interpolator(ease_curve))
	_press_tween.finished.connect(
		func() -> void:
			button_anim_finish.emit()
			# 按下动画结束后根据 hover 状态回到对应缩放
			_apply_hover_scale(_is_hovered)
			_press_tween.kill()
	)

func _on_mouse_entered() -> void:
	_is_hovered = true
	if disabled:
		return
	if hover_sound:
		AudioManager.play_sound(hover_sound)
	# 按下动画期间不抢占 scale
	if _press_tween and _press_tween.is_running():
		return
	_apply_hover_scale(true)

func _on_mouse_exited() -> void:
	_is_hovered = false
	if _press_tween and _press_tween.is_running():
		return
	_apply_hover_scale(false)

func _apply_hover_scale(hovered: bool) -> void:
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
	var target_scale: Vector2 = Vector2.ONE * hover_scale if hovered else Vector2.ONE
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", target_scale, hover_duration)

func _refresh_disabled_visual() -> void:
	if not auto_gray_when_disabled:
		return
	modulate = disabled_modulate if disabled else _normal_modulate
