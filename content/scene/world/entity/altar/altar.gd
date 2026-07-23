class_name Altar
extends Entity

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	player.max_health = player.default_max_health
	player.health = player.max_health
