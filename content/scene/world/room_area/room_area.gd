class_name RoomArea
extends Area2D

@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in get_children():
		if n is CollisionShape2D:
			phantom_camera_2d.limit_target = (n as CollisionShape2D).get_path()
	phantom_camera_2d.follow_target = get_tree().get_first_node_in_group("Player")


func enter_room() -> void:
	phantom_camera_2d.priority = 10


func exit_room() -> void:
	phantom_camera_2d.priority = 1


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		enter_room()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		exit_room()
