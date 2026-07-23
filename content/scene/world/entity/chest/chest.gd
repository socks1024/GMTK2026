class_name Chest
extends Entity

@export var money: int = 0
@export var key: int = 0

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var _opened: bool


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	if !_opened:
		sprite.self_modulate.a = 0.5
		player.money_count += money
		player.key_count += key
		_opened = true
