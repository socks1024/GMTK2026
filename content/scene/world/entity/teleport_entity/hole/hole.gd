class_name Hole
extends Entity


@export var to: Marker2D


func on_touched_by_player(player: Player) -> void:
	player.global_position = to.global_position
