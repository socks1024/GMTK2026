class_name ExplodeBarrel
extends Box

@export var radius: float = 80
@export var damage: int = 4
@export var duration: float = 0.5

@onready var explosion: Explosion = $Explosion
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $AnimatableBody2D/CollisionShape2D


func explode(radius: float, damage: int, duration: float) -> void:
	explosion.trigger_explosion.call_deferred(radius, damage, duration)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	push_box(direction)


func on_hit_by_fireball(direction: Vector2) -> void:
	explode(radius, damage, duration)


func on_hit_by_explosion(direction: Vector2) -> void:
	explode(radius, damage, duration)


func destroy() -> void:
	sprite_2d.hide()
	collision_shape_2d.disabled = true
