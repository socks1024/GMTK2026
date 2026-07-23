class_name Lever
extends Trigger


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	is_on = !is_on
	trigger_switched.emit(is_on)
