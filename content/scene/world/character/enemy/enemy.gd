@abstract class_name Enemy
extends Character

@export var touch_damage: int = 4


func _ready() -> void:
	max_health = default_max_health


func _on_hitbox_body_enter(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.take_common_damage(touch_damage)


func _on_enemy_died() -> void:
	queue_free()
