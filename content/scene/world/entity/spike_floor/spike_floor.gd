class_name SpikeFloor
extends Entity

@export var damage: int = 4

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	sprite.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.take_health_damage(damage, (player.global_position - self.global_position).normalized())
