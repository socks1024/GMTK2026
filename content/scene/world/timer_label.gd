extends Label


var start_time: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time: int = (Time.get_ticks_msec() - start_time) / 1000
	var minutes = time / 60
	var seconds = time % 60
	text = "%02d:%02d" % [minutes, seconds]
