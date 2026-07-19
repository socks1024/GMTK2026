extends StackableControl

## 返回主菜单时发出，由 main.gd 处理游戏世界的清理
signal back_to_start

@export var settings_menu_packed: PackedScene
@export var help_menu_packed: PackedScene


## 控件被 pop 移除时恢复游戏
func _on_removed() -> void:
	get_tree().paused = false
	queue_free()


## 继续游戏：pop 自己，触发 _on_removed 恢复游戏
func _on_resume_anim_finish() -> void:
	_pop_related_layer()


## 返回主菜单
func _on_back_to_start_anim_finish() -> void:
	_pop_related_layer()
	back_to_start.emit()


## 打开设置
func _on_settings_anim_finish() -> void:
	var settings_menu: StackableControl = settings_menu_packed.instantiate()
	UIStackManager.push(settings_menu, "menu")


## 查看游戏说明
func _on_help_anim_finish() -> void:
	var help_menu: StackableControl = help_menu_packed.instantiate()
	UIStackManager.push(help_menu, "menu")


func _on_save_game_button_anim_finish() -> void:
	SaveServer.quick_save_to_curr_slot()
