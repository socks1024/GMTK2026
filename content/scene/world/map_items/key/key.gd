class_name DoorKey
extends MapItem

func interact(player: Player) -> void:
	player.key_count += 1
	queue_free()
