class_name Lever
extends MapItem

signal lever_switched(is_on: bool)

@export var binded_mechanics: Array[MechanicItem]

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func touch_interact(player: Player) -> void:
	pass


func hit_interact(player: Player) -> void:
	is_on = !is_on
	lever_switched.emit(is_on)
	for binded_mechanic in binded_mechanics:
		binded_mechanic.mechanic_interact(is_on)
