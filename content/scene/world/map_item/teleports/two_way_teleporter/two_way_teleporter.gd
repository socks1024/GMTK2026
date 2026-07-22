class_name TwoWayTeleporter
extends MapItem

@export var to: TwoWayTeleporter

var is_destination: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func touch_interact(player: Player) -> void:
	if is_destination:
		is_destination = false
	else:
		to.is_destination = true
		player.global_position = to.global_position


func hit_interact(player: Player) -> void:
	pass
