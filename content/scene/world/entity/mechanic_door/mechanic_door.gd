class_name MechanicDoor
extends Entity

@export var trigger: Trigger

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.trigger_switched.connect(
		func(b):
			if b: open()
			else: close()
	)


func open() -> void:
	sprite.hide()
	collision_shape_2d.set_deferred("disabled",true)


func close() -> void:
	sprite.show()
	collision_shape_2d.set_deferred("disabled",false)
