class_name PressurePlate
extends Trigger

@onready var area_2d: Area2D = $Area2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !is_on:
		is_on = true
		trigger_switched.emit(is_on)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if !area_2d.has_overlapping_bodies():
		is_on = false
		trigger_switched.emit(is_on)
