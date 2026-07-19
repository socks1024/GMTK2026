extends Node

@export_file("*.tscn") var game_world_path: String
@export_file("*.tscn") var loading_scene_path: String

@export var start_menu_packed: PackedScene
@export var pause_menu_packed: PackedScene

@onready var world: Node = $World

var _game_root: Node


func _ready() -> void:
	_push_start_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# 仅在游戏运行中且未暂停时，打开暂停菜单
		if _game_root != null and not get_tree().paused:
			_pause_game()
			get_viewport().set_input_as_handled()


func _instantiate_game_world() -> void:
	if game_world_path == null or game_world_path == "":
		CLog.e("Game World Path not assigned!")
		return
	UIStackManager.clear_layer("menu")
	_game_root = await SceneUtils.instantiate_scene_by_load_control(world,game_world_path,loading_scene_path)


func _on_new_game() -> void:
	if SaveServer.is_save_exists("001"):
		SaveServer.delete_slot("001")
	SaveServer.create_new_save("001")
	SaveServer.load_from_slot("001")
	_instantiate_game_world()


func _on_continue_game() -> void:
	SaveServer.load_from_slot("001")
	_instantiate_game_world()


## 暂停游戏并通过 UIStackManager 推入暂停菜单
func _pause_game() -> void:
	get_tree().paused = true
	var pause_menu: StackableControl = pause_menu_packed.instantiate()
	pause_menu.back_to_start.connect(_on_back_to_start)
	UIStackManager.push(pause_menu, "menu")


## 暂停菜单 - 返回主菜单
func _on_back_to_start() -> void:
	_game_root.queue_free()
	_game_root = null
	SaveServer.unload()
	_push_start_menu()


func _push_start_menu() -> void:
	var start_menu = start_menu_packed.instantiate()
	start_menu.new_game_clicked.connect(_on_new_game)
	start_menu.continue_clicked.connect(_on_continue_game)
	UIStackManager.push(start_menu, "menu")
