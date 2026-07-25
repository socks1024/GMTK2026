class_name HeartContainer
extends PickableEntity

@export var heal_amount: int = 4


func on_picked_by_player(player: Player) -> void:
	player.gain_max_health_and_heal_all(heal_amount)
	queue_free()
