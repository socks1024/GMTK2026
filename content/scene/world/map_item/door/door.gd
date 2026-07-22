class_name Door
extends MapItem

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func open() -> void:
	sprite.hide()
	collision_shape_2d.set_deferred("disabled", true)


func touch_interact(player: Player) -> void:
	if player.key_count > 0:
		open()
		player.key_count -= 1


func hit_interact(player: Player) -> void:
	if player.key_count > 0:
		open()
		player.key_count -= 1
