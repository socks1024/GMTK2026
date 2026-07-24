@abstract class_name Enemy
extends Character

@export var touch_damage: int = 4
@export var p_heart: PackedScene = preload("uid://cqp010syu714")

var _default_pos: Vector2
var _is_player_in_room: bool = false

func _ready() -> void:
	super._ready()
	_default_pos = position
	character_dead.connect(_on_enemy_died.call_deferred)


func _on_hitbox_body_enter(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.take_common_damage(touch_damage)


func reset() -> void:
	health = max_health
	position = _default_pos
	for n in NodeUtils.recursive_get_children(self, true):
		if n is CollisionShape2D:
			n.disabled = false
		if n is Sprite2D or n is AnimatedSprite2D:
			n.show()


func _on_enemy_died() -> void:
	var heart: Heart = p_heart.instantiate()
	get_parent().add_child(heart)
	heart.position = self.position
	
	for n in NodeUtils.recursive_get_children(self, true):
		if n is CollisionShape2D:
			n.disabled = true
		if n is Sprite2D or n is AnimatedSprite2D:
			n.hide()


func on_player_enter_room() -> void:
	_is_player_in_room = true

func on_player_leave_room() -> void:
	_is_player_in_room = false
	reset()
