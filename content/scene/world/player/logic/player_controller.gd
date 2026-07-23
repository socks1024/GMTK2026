class_name PlayerController
extends Node

signal facing_direction_changed(facing_direction_changed: Vector2)

@export_group("Input Actions")
@export var player_input_context: GUIDEMappingContext
@export var move_action: GUIDEAction
@export var attack_action: GUIDEAction
@export var evade_action: GUIDEAction
@export var spell_1_action: GUIDEAction
@export var spell_2_action: GUIDEAction

var attack_power_input: PowerInput
var evade_power_input: PowerInput
var spell_1_power_input: PowerInput
var spell_2_power_input: PowerInput

var move_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	GUIDE.enable_mapping_context(player_input_context)
	attack_power_input = PowerInput.new(attack_action)
	evade_power_input = PowerInput.new(evade_action)
	spell_1_power_input = PowerInput.new(spell_1_action)
	spell_2_power_input = PowerInput.new(spell_2_action)


func _physics_process(_delta: float) -> void:
	if move_action.value_axis_2d.length() > 0.1:
		#var angle = move_action.value_axis_2d.normalized().angle()
		#var snapped_vec = round(angle / (PI / 2)) * (PI / 2)
		#move_direction = Vector2.RIGHT.rotated(snapped_vec).normalized()
		
		if abs(move_action.value_axis_2d.x) > abs(move_action.value_axis_2d.y):
			if move_action.value_axis_2d.x > 0:
				move_direction = Vector2.RIGHT
			else:
				move_direction = Vector2.LEFT
		else:
			if move_action.value_axis_2d.y > 0:
				move_direction = Vector2.DOWN
			else:
				move_direction = Vector2.UP
		
		if move_direction != facing_direction:
			facing_direction = move_direction
			facing_direction_changed.emit(facing_direction)
	else:
		move_direction = Vector2.ZERO


class PowerInput:
	signal power_started
	signal power_completed(time: float)
	
	var is_power_triggering: bool = false
	
	var _power_action: GUIDEAction
	var _power_start_time_msec: int
	
	func _init(action: GUIDEAction) -> void:
		_power_action = action
		_power_action.just_triggered.connect(_on_power_action_started)
		_power_action.completed.connect(_on_power_action_completed)
	
	func get_power_duration() -> float:
		return (Time.get_ticks_msec() - _power_start_time_msec) / 1000.0
	
	func _on_power_action_started() -> void:
		is_power_triggering = true
		power_started.emit()
		_power_start_time_msec = Time.get_ticks_msec()
	
	func _on_power_action_completed() -> void:
		is_power_triggering = false
		power_completed.emit(get_power_duration())
		_power_start_time_msec = 0
