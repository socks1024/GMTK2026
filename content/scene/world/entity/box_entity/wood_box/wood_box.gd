class_name WoodBox
extends Box


func _ready() -> void:
	CLog.o(raycast_collision_mask)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	CLog.o("try push box")
	push_box(direction)
