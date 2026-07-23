@abstract class_name Entity
extends Node2D

func on_touched_by_player(player: Player) -> void:
	pass

func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	pass

func on_hit_by_fireball(direction: Vector2) -> void:
	pass

func on_hit_by_explosion(direction: Vector2) -> void:
	pass
