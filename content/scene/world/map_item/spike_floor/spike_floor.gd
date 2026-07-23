class_name SpikeFloor
extends MapItem

@export var damage: int = 4

@onready var sprite: Sprite2D = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func touch_interact(player: Player) -> void:
	player.take_health_damage(damage)


func hit_interact(player: Player) -> void:
	pass
