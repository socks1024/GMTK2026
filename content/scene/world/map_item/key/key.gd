class_name DoorKey
extends MapItem

func touch_interact(player: Player) -> void:
	player.key_count += 1
	queue_free()


func hit_interact(player: Player) -> void:
	player.key_count += 1
	queue_free()
