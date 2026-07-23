class_name RoomArea
extends Area2D

signal player_enter_room(player: Player)
signal player_exit_room(player: Player)

@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in get_children():
		if n is CollisionShape2D:
			phantom_camera_2d.limit_target = (n as CollisionShape2D).get_path()


func enter_room(player: Player) -> void:
	phantom_camera_2d.follow_target = player
	phantom_camera_2d.priority = 10
	player_enter_room.emit(player)


func exit_room(player: Player) -> void:
	# phantom_camera_2d.follow_target = null
	phantom_camera_2d.priority = 1
	player_exit_room.emit(player)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_room(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		exit_room(body as Player)
