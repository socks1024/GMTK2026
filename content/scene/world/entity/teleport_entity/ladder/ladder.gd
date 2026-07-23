class_name Ladder
extends Entity

@export var to: Ladder

var is_destination: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func on_touched_by_player(player: Player) -> void:
	if is_destination:
		is_destination = false
	else:
		to.is_destination = true
		player.global_position = to.global_position
