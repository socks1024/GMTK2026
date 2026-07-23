@abstract class_name Enemy
extends CharacterBody2D

@export var default_max_health: int = 4
@export var touch_damage: int = 4

var _max_health: int = 1
var max_health: int:
	get():
		return _max_health
	set(v):
		_max_health = clampi(v, 1, 999)
		health = mini(max_health, health)

var _health: int = 1
var health: int:
	get():
		return _health
	set(v):
		_health = clampi(v, 0, max_health)
		if _health <= 0: _on_enemy_died()


func take_health_damage(damage: int) -> void:
	health -= damage


func take_max_health_damage(damage: int) -> void:
	max_health -= damage


func take_common_damage(damage: int) -> void:
	if damage <= health:
		take_health_damage(damage)
	else:
		var max_health_damage: int = damage - health
		take_health_damage(health)
		take_max_health_damage(max_health_damage)


func _ready() -> void:
	max_health = default_max_health


func _on_hitbox_body_enter(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.take_common_damage(touch_damage)


func _on_enemy_died() -> void:
	queue_free()
