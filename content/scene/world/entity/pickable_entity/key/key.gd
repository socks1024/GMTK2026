class_name DoorKey
extends PickableEntity

func on_picked_by_player(player: Player) -> void:
	player.key_count += 1
	queue_free()
