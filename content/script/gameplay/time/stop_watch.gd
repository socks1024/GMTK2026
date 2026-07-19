class_name StopWatch
extends RefCounted

var _start_time: int

func start() -> void:
	_start_time = Time.get_ticks_msec()


func get_time_msec() -> int:
	return Time.get_ticks_msec() - _start_time


func get_time_sec() -> float:
	return get_time_msec() / 1000.0
