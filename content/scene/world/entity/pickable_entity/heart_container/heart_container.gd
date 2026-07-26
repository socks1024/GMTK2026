class_name HeartContainer
extends PickableEntity

@export var heal_amount: int = 4

func _ready() -> void:
	Complement.total_count += 1


func on_picked_by_player(player: Player) -> void:
	player.gain_max_health_and_heal_all(heal_amount)
	Complement.current_count += 1
	queue_free()
