class_name WoodBox
extends Box


func _ready() -> void:
	CLog.o(raycast_collision_mask)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	push_box(direction)

func on_hit_by_fireball(direction: Vector2) -> void:
	push_box(direction)

func on_hit_by_explosion(direction: Vector2) -> void:
	destroy()
