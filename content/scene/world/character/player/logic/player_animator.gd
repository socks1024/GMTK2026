class_name PlayerAnimator
extends Node

@export var animation_tree: AnimationTree
@export var player: Player
@export var player_controller: PlayerController
@export var animated_sprite_2d: AnimatedSprite2D
@export var p_missile: PackedScene
@export var p_explosion: PackedScene

@export_group("CollisionShapes")
@export var left_sword_hitbox: CollisionShape2D
@export var right_sword_hitbox: CollisionShape2D
@export var down_sword_hitbox: CollisionShape2D
@export var up_sword_hitbox: CollisionShape2D

@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	player_controller.attack_power_input.power_completed.connect(
		func(t): if t < 0.5: _travel_to_animation("Attack")
	)
	player_controller.attack_power_input.power_completed.connect(
		func(t): if t > 0.5: missile_launch()
	)
	player_controller.spell_1_power_input.power_completed.connect(
		func(t): missile_launch()
	)
	player_controller.spell_2_power_input.power_completed.connect(
		func(t): self_explode()
	)


func _process(_delta: float) -> void:
	var dir: Vector2 = Vector2(player.facing_direction.x, -player.facing_direction.y)
	animation_tree.set("parameters/Idle/blend_position", dir)
	animation_tree.set("parameters/Move/blend_position", dir)
	animation_tree.set("parameters/Attack/blend_position", dir)


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


func missile_launch():
	var missile: MagicMissile = p_missile.instantiate()
	missile.damage = 4
	missile.speed = 300
	get_tree().current_scene.add_child(missile)
	missile.global_position = player.position + player.facing_direction * 80
	missile.look_at(player.position + player.facing_direction * 80 * 2)


func self_explode():
	var explosion: Explosion = p_explosion.instantiate()
	player.add_child(explosion)
	explosion.trigger_explosion.call_deferred()


func _travel_to_animation(anim_name: String):
	state_machine.travel(anim_name)
