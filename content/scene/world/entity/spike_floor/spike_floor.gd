class_name SpikeFloor
extends Entity

@export var damage: int = 4

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	sprite.play()


func on_touched_by_player(player: Player) -> void:
	player.take_health_damage(damage)
	player.move_and_collide((player.global_position - self.global_position).normalized() * 80)
