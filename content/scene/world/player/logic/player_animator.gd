class_name PlayerAnimator
extends Node

@export var animation_tree: AnimationTree
@export var player: Player
@export var player_controller: PlayerController
@export var animated_sprite_2d: AnimatedSprite2D

@export_group("CollisionShapes")
@export var left_sword_hitbox: CollisionShape2D
@export var right_sword_hitbox: CollisionShape2D
@export var down_sword_hitbox: CollisionShape2D
@export var up_sword_hitbox: CollisionShape2D

@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	player_controller.attack_power_input.power_completed.connect(
		func(t): if t < 0.5: sword_attack()
	)
	player_controller.attack_power_input.power_completed.connect(
		func(t): if t > 0.5: missile_launch()
	)
	player.live_form_changed.connect(
		func(b):
			if b:
				animated_sprite_2d.self_modulate = Color.WHITE
			else:
				animated_sprite_2d.self_modulate = Color(0.263, 0.329, 1.0)
	)


func _process(delta: float) -> void:
	var dir: Vector2 = Vector2(player.facing_direction.x, -player.facing_direction.y)
	animation_tree.set("parameters/Idle/blend_position", dir)
	animation_tree.set("parameters/Move/blend_position", dir)


func set_sword_hitbox(enable: bool) -> void:
	match player.facing_direction:
		Vector2.RIGHT:
			right_sword_hitbox.disabled = !enable
		Vector2.LEFT:
			left_sword_hitbox.disabled = !enable
		Vector2.UP:
			up_sword_hitbox.disabled = !enable
		Vector2.DOWN:
			down_sword_hitbox.disabled = !enable
		_:
			CLog.w("Invalid facing direction : " + str(player.facing_direction))
			right_sword_hitbox.disabled = !enable


func sword_attack():
	_travel_to_animation("Attack")


func missile_launch():
	pass


func _travel_to_animation(anim_name: String):
	var state_machine = animation_tree.get("parameters/playback")
	state_machine.travel(anim_name)
