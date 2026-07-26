extends Enemy

@export_group("Missile")
@export var p_missile: PackedScene = preload("uid://cnatycbh2lybr")
@export var missile_speed: float = 300
@export var missile_damage: int = 4

@export_group("Shoot")
@export var shoot_offset: float = 80
@export var shoot_interval: float = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var down_ray_cast_2d: RayCast2D = $DownRayCast2D
@onready var left_ray_cast_2d: RayCast2D = $LeftRayCast2D
@onready var right_ray_cast_2d: RayCast2D = $RightRayCast2D
@onready var up_ray_cast_2d: RayCast2D = $UpRayCast2D
@onready var timer: Timer = $Timer

var _is_shooting: bool = false


func _ready() -> void:
	super._ready()
	animated_sprite_2d.play()
	timer.timeout.connect(func():_is_shooting = false)


func _physics_process(delta: float) -> void:
	if _is_player_in_room:
		if _is_shooting || health <= 0:
			return
		if is_valid_collider(down_ray_cast_2d):
			shoot.call_deferred(Vector2.DOWN)
		if is_valid_collider(left_ray_cast_2d):
			shoot.call_deferred(Vector2.LEFT)
		if is_valid_collider(right_ray_cast_2d):
			shoot.call_deferred(Vector2.RIGHT)
		if is_valid_collider(up_ray_cast_2d):
			shoot.call_deferred(Vector2.UP)


func is_valid_collider(raycast: RayCast2D) -> bool:
	var collider = raycast.get_collider()
	return collider && (collider is Character || collider.get_parent() is Entity)


func shoot(shoot_direction: Vector2) -> void:
	var missile: MagicMissile = p_missile.instantiate()
	missile.damage = missile_damage
	missile.speed = missile_speed
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position + shoot_direction * shoot_offset
	missile.look_at(global_position + shoot_direction * shoot_offset * 2)
	timer.start(shoot_interval)
	_is_shooting = true


func _on_enemy_died() -> void:
	super._on_enemy_died()
	down_ray_cast_2d.enabled = false
	left_ray_cast_2d.enabled = false
	right_ray_cast_2d.enabled = false
	up_ray_cast_2d.enabled = false


func reset() -> void:
	super.reset()
	down_ray_cast_2d.enabled = true
	left_ray_cast_2d.enabled = true
	right_ray_cast_2d.enabled = true
	up_ray_cast_2d.enabled = true
