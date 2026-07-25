class_name Altar
extends Entity

@export var revive_pos: Marker2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	if player:
		player.max_health = player.default_max_health
		player.health = player.max_health
		player.revive_position = revive_pos.global_position
		player.live_timer.start(player.max_live_time)
