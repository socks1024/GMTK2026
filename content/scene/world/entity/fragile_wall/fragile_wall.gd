class_name FragileWall
extends Entity

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D


func destroy() -> void:
	sprite.hide()
	collision_shape_2d.set_deferred("disabled", true)


func on_hit_by_explosion(direction: Vector2) -> void:
	destroy.call_deferred()


func reset() -> void:
	pass
