class_name PlayerAnimator
extends Node

@export var animation_tree: AnimationTree
@export var player: Player
@export var player_controller: PlayerController
@export var magic_animation: AnimatedSprite2D
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
		func(t):if t < 0.3: _travel_to_animation("Attack")
	)
	player_controller.evade_power_input.power_started.connect(
		func(): magic_animation.play()
	)
	player_controller.evade_power_input.power_completed.connect(
		func(t):
			magic_animation.stop()
			if t > 0.3 && t <= 1: _travel_to_animation("Shoot")
			elif t > 1: _travel_to_animation("Magic")
	)
	player.get_hurt.connect(
		func(): _travel_to_animation("Hurt")
	)


func _physics_process(delta: float) -> void:
	player.velocity = player_controller.move_direction * player.speed
	player.move_and_slide()


func _process(_delta: float) -> void:
	var dir: Vector2 = Vector2(player_controller.facing_direction.x, -player_controller.facing_direction.y)
	animation_tree.set("parameters/Idle/blend_position", dir)
	animation_tree.set("parameters/Move/blend_position", dir)
	animation_tree.set("parameters/Attack/blend_position", dir)
	animation_tree.set("parameters/Hurt/blend_position", dir)
	animation_tree.set("parameters/Magic/blend_position", dir)
	animation_tree.set("parameters/Shoot/blend_position", dir)


func set_sword_hitbox(enable: bool) -> void:
	match player_controller.facing_direction:
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


func shoot_fireball():
	var missile: MagicMissile = p_missile.instantiate()
	missile.damage = 4
	missile.speed = 300
	get_tree().current_scene.add_child(missile)
	missile.global_position = player.position + player_controller.facing_direction * 80
	missile.look_at(player.position + player_controller.facing_direction * 80 * 2)


func self_explode():
	var explosion: Explosion = p_explosion.instantiate()
	player.get_parent().add_child(explosion)
	explosion.global_position = player.global_position
	explosion.trigger_explosion.call_deferred()


func _travel_to_animation(anim_name: String):
	state_machine.travel(anim_name)
