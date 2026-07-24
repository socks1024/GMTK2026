class_name Clock
extends PickableEntity

@export var extra_live_time: float = 30


func on_picked_by_player(player: Player) -> void:
	player.gain_live_time(30)
	queue_free()
