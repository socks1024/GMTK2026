class_name MirrorBox
extends Box




func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	push_box(direction)
