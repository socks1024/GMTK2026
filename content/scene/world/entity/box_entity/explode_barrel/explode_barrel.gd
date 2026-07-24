class_name ExplodeBarrel
extends Box

@export var radius: float = 80
@export var damage: int = 4
@export var duration: float = 0.5
@export var p_explosion: PackedScene = preload("uid://drhubgdeg3ekc")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $AnimatableBody2D/CollisionShape2D

var exploded: bool = false

func explode(radius: float, damage: int, duration: float) -> void:
	if !exploded:
		exploded = true
		var explosion: Explosion = p_explosion.instantiate()
		add_child(explosion)
		explosion.explode_finished.connect(destroy.call_deferred)
		explosion.trigger_explosion(radius, damage, duration)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	push_box(direction)


func on_hit_by_fireball(direction: Vector2) -> void:
	explode.call_deferred(radius, damage, duration)


func on_hit_by_explosion(direction: Vector2) -> void:
	explode.call_deferred(radius, damage, duration)

func reset() -> void:
	super.reset()
	exploded = false
