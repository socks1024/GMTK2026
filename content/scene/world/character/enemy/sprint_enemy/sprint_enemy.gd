extends Enemy

@export var sprint_speed: float = 300

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var down_ray_cast_2d: RayCast2D = $DownRayCast2D
@onready var left_ray_cast_2d: RayCast2D = $LeftRayCast2D
@onready var right_ray_cast_2d: RayCast2D = $RightRayCast2D
@onready var up_ray_cast_2d: RayCast2D = $UpRayCast2D
@onready var down_collision_shape_2d: CollisionShape2D = $PushArea2D/DownCollisionShape2D
@onready var up_collision_shape_2d: CollisionShape2D = $PushArea2D/UpCollisionShape2D
@onready var left_collision_shape_2d: CollisionShape2D = $PushArea2D/LeftCollisionShape2D
@onready var right_collision_shape_2d: CollisionShape2D = $PushArea2D/RightCollisionShape2D

var sprint_direction: Vector2
var attack_direction: Vector2

var known_objects: Array[CollisionObject2D]

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play()


func _physics_process(delta: float) -> void:
	if !_is_player_in_room:
		return
	if sprint_direction == Vector2.ZERO:
		sprint_direction = get_sprint_direction()
	
	if sprint_direction != Vector2.ZERO:
		var collide = move_and_collide(sprint_direction, true)
		if collide:
			attack_direction = sprint_direction
			sprint_direction = Vector2.ZERO
			set_attack_collision_disabled(false)
			get_tree().create_timer(0.3).timeout.connect(
				func(): 
					set_attack_collision_disabled(true)
					attack_direction = Vector2.ZERO
			)
		else:
			velocity = sprint_direction * sprint_speed
			move_and_slide()


func get_sprint_direction() -> Vector2:
	var return_direction: Vector2 = Vector2.ZERO
	
	if down_ray_cast_2d.get_collider() && known_objects.find(down_ray_cast_2d.get_collider()) == -1:
		return_direction = Vector2.DOWN
	if left_ray_cast_2d.get_collider() && known_objects.find(left_ray_cast_2d.get_collider()) == -1:
		return_direction = Vector2.LEFT
	if right_ray_cast_2d.get_collider() && known_objects.find(right_ray_cast_2d.get_collider()) == -1:
		return_direction = Vector2.RIGHT
	if up_ray_cast_2d.get_collider() && known_objects.find(up_ray_cast_2d.get_collider()) == -1:
		return_direction = Vector2.UP

	var objects: Array[CollisionObject2D]
	if down_ray_cast_2d.get_collider():
		objects.append(down_ray_cast_2d.get_collider())
	if left_ray_cast_2d.get_collider():
		objects.append(left_ray_cast_2d.get_collider())
	if right_ray_cast_2d.get_collider():
		objects.append(right_ray_cast_2d.get_collider())
	if up_ray_cast_2d.get_collider():
		objects.append(up_ray_cast_2d.get_collider())
	known_objects = objects
	
	return return_direction


func set_attack_collision_disabled(disabled: bool) -> void:
	match attack_direction:
		Vector2.DOWN:
			down_collision_shape_2d.disabled = disabled
		Vector2.UP:
			up_collision_shape_2d.disabled = disabled
		Vector2.LEFT:
			left_collision_shape_2d.disabled = disabled
		Vector2.RIGHT:
			right_collision_shape_2d.disabled = disabled


func _on_push_area_2d_body_entered(body: Node) -> void:
	if body.get_parent() is Entity:
		(body.get_parent() as Entity).on_hit_by_sword(attack_direction, null)


func _on_enemy_died() -> void:
	super._on_enemy_died()
	sprint_direction = Vector2.ZERO
	attack_direction = Vector2.ZERO
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
