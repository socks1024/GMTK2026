@abstract class_name Trigger
extends Entity

signal trigger_switched(is_on: bool)

@export var trigger_color: Color

var is_on: bool = false


func _ready() -> void:
	modulate = trigger_color
