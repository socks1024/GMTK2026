class_name Altar
extends Entity

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D


func on_touched_by_player(player: Player) -> void:
	save_progress(player)


func on_hit_by_sword(direction: Vector2, player: Player) -> void:
	if player: save_progress(player)


func save_progress(player: Player) -> void:
	player.health = player.max_health
	player.revive_position = player.global_position
	player.live_timer.start(player.max_live_time)
