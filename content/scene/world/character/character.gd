@abstract class_name Character
extends CharacterBody2D

signal health_changed(value: int)
signal max_health_changed(value: int)

signal character_dead

@export var default_max_health: int = 12

var _max_health: int = 1
var max_health: int:
	get():
		return _max_health
	set(v):
		_max_health = clampi(v, 1, 999)
		health = mini(max_health, health)
		max_health_changed.emit(max_health)

var _health: int = 1
var health: int:
	get():
		return _health
	set(v):
		_health = clampi(v, 0, max_health)
		health_changed.emit(health)
		if _health <= 0:
			character_dead.emit()


func _ready() -> void:
	max_health = default_max_health
	health = max_health


func take_health_damage(amount: int) -> void:
	health -= amount


func take_max_health_damage(amount: int) -> void:
	max_health -= amount


func take_common_damage(amount: int) -> void:
	#if amount <= health:
		#take_health_damage(amount)
	#else:
		#var max_health_damage: int = amount - health
		#take_health_damage(health)
		#take_max_health_damage(max_health_damage)
	take_health_damage(amount)


func heal_health(amount: int) -> void:
	health += amount


func gain_max_health_and_heal_all(amount: int) -> void:
	max_health += amount
	health = max_health
