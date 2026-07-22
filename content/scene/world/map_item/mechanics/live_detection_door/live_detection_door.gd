class_name LiveDetectionDoor
extends MechanicItem

@export var open_on_live: bool = true

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if Player.quick_get_player():
		if Player.quick_get_player().is_living() && open_on_live:
			open()
		else:
			close()


func open() -> void:
	sprite.hide()
	collision_shape_2d.set_deferred("disabled",true)


func close() -> void:
	sprite.show()
	collision_shape_2d.set_deferred("disabled",false)


func touch_interact(player: Player) -> void:
	pass


func hit_interact(player: Player) -> void:
	pass


func mechanic_interact(is_on: bool) -> void:
	pass
