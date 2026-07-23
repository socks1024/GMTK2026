class_name Heart
extends PickableEntity

@export var heal_amount: int = 4


func on_picked_by_player(player: Player) -> void:
	if player.max_health - player.health >= heal_amount:
		player.heal_health(heal_amount)
		queue_free()
