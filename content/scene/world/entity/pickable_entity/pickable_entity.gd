@abstract class_name PickableEntity
extends Entity

func on_touched_by_player(player: Player) -> void:
	on_picked_by_player(player)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	on_picked_by_player(player)


func on_picked_by_player(player: Player) -> void:
	pass
