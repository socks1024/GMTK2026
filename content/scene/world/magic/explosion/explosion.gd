class_name Explosion
extends Node2D

signal explode_finished

var radius: float = 80
var damage: int = 4
var duration: float = 0.5

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer

var _is_exploding: bool = false

func trigger_explosion(rad: float = 80, dam: int = 4, dur: float = 0.5) -> void:
	if _is_exploding:
		return
	radius = rad
	damage = dam
	duration = dur
	
	sprite_2d.scale = Vector2.ONE * radius / 16
	collision_shape_2d.shape.radius = radius
	sprite_2d.show()
	collision_shape_2d.disabled = false
	
	timer.start(duration)
	_is_exploding = true


func on_explosion_finished() -> void:
	sprite_2d.hide()
	collision_shape_2d.disabled = true
	_is_exploding = false
	explode_finished.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Character:
		(body as Character).take_health_damage(damage)
	
	if body.get_parent() is Entity:
		(body.get_parent() as Entity).on_hit_by_explosion(MathUtils.vector2_to_4_direction(body.global_position - global_position))
