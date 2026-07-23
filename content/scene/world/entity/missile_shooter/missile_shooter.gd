class_name MissileShooter
extends Entity

@export_group("Missile")
@export var p_missile: PackedScene
@export var missile_speed: float = 300
@export var missile_damage: int = 4

@export_group("Shoot")
@export var shoot_offset: float = 80
@export var shoot_direction: Vector2 = Vector2.RIGHT
@export var auto_shoot: bool = false
@export var auto_shoot_interval: float = 4
@export var shoot_trigger: Trigger

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(shoot)
	timer.wait_time = auto_shoot_interval
	
	if shoot_trigger:
		shoot_trigger.trigger_switched.connect(
			func(b):
				if b: start_shoot()
				else: stop_shoot()
		)
	
	if auto_shoot:
		start_shoot()


func start_shoot() -> void:
	shoot()
	timer.start()


func stop_shoot() -> void:
	timer.stop()


func shoot() -> void:
	var missile: MagicMissile = p_missile.instantiate()
	missile.damage = missile_damage
	missile.speed = missile_speed
	get_tree().current_scene.add_child(missile)
	missile.global_position = position + shoot_direction * shoot_offset
	missile.look_at(position + shoot_direction * shoot_offset * 2)
