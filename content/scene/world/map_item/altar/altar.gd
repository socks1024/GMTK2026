class_name Altar
extends MapItem

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func touch_interact(player: Player) -> void:
	pass


func hit_interact(player: Player) -> void:
	player.max_health = player.default_max_health
	player.health = player.max_health
