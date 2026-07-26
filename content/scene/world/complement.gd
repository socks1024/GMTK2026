class_name Complement
extends Label

static var total_count: int
static var current_count: int

@export var door: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(current_count) + "/" + str(total_count)
	if current_count >= total_count && total_count > 0:
		door.queue_free()
