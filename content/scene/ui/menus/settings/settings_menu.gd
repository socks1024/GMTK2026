extends StackableControl


func _on_back_button_anim_finish() -> void:
	_pop_related_layer()


func _on_reset_all_button_anim_finish() -> void:
	SettingsManager.reset_all_settings()
	for c in find_children("*","ConfigControl",true,false):
		c.set_control_value(c.get_default_value())
