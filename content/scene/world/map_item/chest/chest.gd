class_name Chest
extends MapItem

@export var money: int = 0
@export var key: int = 0

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var _opened: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func touch_interact(player: Player) -> void:
	pass


func hit_interact(player: Player) -> void:
	if !_opened:
		sprite.self_modulate.a = 0.5
		player.money_count += money
		player.key_count += key
		_opened = true
