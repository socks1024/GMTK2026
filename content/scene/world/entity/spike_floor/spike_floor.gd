class_name SpikeFloor
extends Entity

@export var damage: int = 4


func on_touched_by_player(player: Player) -> void:
	player.take_health_damage(damage)
