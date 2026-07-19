extends StackableControl

signal new_game_clicked
signal continue_clicked

@export var settings_menu_packed: PackedScene
@export var credits_menu_packed: PackedScene

@onready var continue_button: CommonButton = $Panel/VBoxContainer/Buttons/Continue


func _ready() -> void:
	continue_button.visible = SaveServer.is_save_exists("001")


func _on_new_game_button_anim_finish() -> void:
	new_game_clicked.emit()


func _on_continue_button_anim_finish() -> void:
	continue_clicked.emit()


func _on_load_selected(slot_id: String) -> void:
	CLog.o("Game Continued with save at slot: %s", slot_id)
	continue_clicked.emit()


func _on_settings_button_anim_finish() -> void:
	var menu = settings_menu_packed.instantiate()
	UIStackManager.push(menu)


func _on_credits_button_anim_finish() -> void:
	var menu = credits_menu_packed.instantiate()
	UIStackManager.push(menu)


func _on_exit_button_anim_finish() -> void:
	get_tree().quit()
