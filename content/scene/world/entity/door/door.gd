class_name Door
extends Entity

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func open() -> void:
	sprite.hide()
	collision_shape_2d.set_deferred("disabled", true)


func open_with_player_key(player: Player) -> void:
	if player.key_count > 0:
		open()
		player.key_count -= 1


func on_touched_by_player(player: Player) -> void:
	open_with_player_key(player)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	open_with_player_key(player)
