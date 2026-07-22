class_name OneWayTeleporter
extends MapItem


@export var to: Marker2D


func touch_interact(player: Player) -> void:
	player.global_position = to.global_position


func hit_interact(player: Player) -> void:
	pass
