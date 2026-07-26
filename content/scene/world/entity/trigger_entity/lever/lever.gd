class_name Lever
extends Trigger

@onready var sprite: Sprite2D = $Sprite

func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	trigger_lever()

func on_hit_by_fireball(direction: Vector2) -> void:
	trigger_lever()

func on_hit_by_explosion(direction: Vector2) -> void:
	trigger_lever()

func trigger_lever() -> void:
	is_on = !is_on
	trigger_switched.emit(is_on)
	sprite.flip_h = is_on

func reset() -> void:
	if is_on:
		is_on = false
		trigger_switched.emit(is_on)
		sprite.flip_h = is_on
