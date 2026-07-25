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

var sprint_direction: Vector2 = Vector2.ZERO
var attack_direction: Vector2 = Vector2.ZERO

var known_objects: Array[CollisionObject2D]

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play("idle")
	get_tree().create_timer(0.1).timeout.connect(update_known_objects)
	diable_all_attack_collision()


func _physics_process(delta: float) -> void:
	if !_is_player_in_room:
		return
	
	if sprint_direction == Vector2.ZERO:
		sprint_direction = get_sprint_direction()
		if sprint_direction != Vector2.ZERO:
			animated_sprite_2d.play("run")
	
	update_known_objects()
	
	if sprint_direction != Vector2.ZERO:
		var collide = move_and_collide(sprint_direction, true)
		if collide:
			animated_sprite_2d.play("idle")
			attack_direction = sprint_direction
			sprint_direction = Vector2.ZERO
			diable_all_attack_collision()
			set_attack_collision_disabled(false)
			get_tree().create_timer(0.3).timeout.connect(
				func(): 
					diable_all_attack_collision()
					attack_direction = Vector2.ZERO
			)
		else:
			velocity = sprint_direction * sprint_speed
			move_and_slide()
		
		if velocity.x > 0: animated_sprite_2d.flip_h = true
		if velocity.x < 0: animated_sprite_2d.flip_h = false


func get_sprint_direction() -> Vector2:
	var return_direction: Vector2 = Vector2.ZERO
	
	if is_target(down_ray_cast_2d):
		return_direction = Vector2.DOWN
	if is_target(left_ray_cast_2d):
		return_direction = Vector2.LEFT
	if is_target(right_ray_cast_2d):
		return_direction = Vector2.RIGHT
	if is_target(up_ray_cast_2d):
		return_direction = Vector2.UP
	
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


func diable_all_attack_collision() -> void:
	down_collision_shape_2d.disabled = true
	left_collision_shape_2d.disabled = true
	right_collision_shape_2d.disabled = true
	up_collision_shape_2d.disabled = true


func _on_push_area_2d_body_entered(body: Node) -> void:
	if body.get_parent() is Entity:
		(body.get_parent() as Entity).on_hit_by_sword(attack_direction, null)


func is_valid_collider(raycast: RayCast2D) -> bool:
	var collider = raycast.get_collider()
	return collider && (collider is Character || collider.get_parent() is Entity)


func is_target(raycast: RayCast2D) -> bool:
	return is_valid_collider(raycast) && known_objects.find(raycast.get_collider()) == -1


func update_known_objects() -> void:
	known_objects.clear()
	if is_valid_collider(down_ray_cast_2d):
		known_objects.append(down_ray_cast_2d.get_collider())
	if is_valid_collider(left_ray_cast_2d):
		known_objects.append(left_ray_cast_2d.get_collider())
	if is_valid_collider(right_ray_cast_2d):
		known_objects.append(right_ray_cast_2d.get_collider())
	if is_valid_collider(up_ray_cast_2d):
		known_objects.append(up_ray_cast_2d.get_collider())


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
	
	sprint_direction = Vector2.ZERO
	attack_direction = Vector2.ZERO
	animated_sprite_2d.play("idle")
	
	update_known_objects()
	diable_all_attack_collision()
	
	down_ray_cast_2d.enabled = true
	left_ray_cast_2d.enabled = true
	right_ray_cast_2d.enabled = true
	up_ray_cast_2d.enabled = true
