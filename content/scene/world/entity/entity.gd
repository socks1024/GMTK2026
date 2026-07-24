@abstract class_name Entity
extends Node2D

var _is_player_in_room: bool = false

func on_touched_by_player(player: Player) -> void:
	pass

func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	pass

func on_hit_by_fireball(direction: Vector2) -> void:
	pass

func on_hit_by_explosion(direction: Vector2) -> void:
	pass

func on_player_enter_room() -> void:
	_is_player_in_room = true

func on_player_leave_room() -> void:
	_is_player_in_room = false
	reset()

func reset() -> void:
	pass
