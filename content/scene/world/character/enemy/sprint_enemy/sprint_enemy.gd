extends Enemy

@export var sprint_speed: float = 300

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var down_ray_cast_2d: RayCast2D = $DownRayCast2D
@onready var left_ray_cast_2d: RayCast2D = $LeftRayCast2D
@onready var right_ray_cast_2d: RayCast2D = $RightRayCast2D
@onready var up_ray_cast_2d: RayCast2D = $UpRayCast2D

var sprint_direction: Vector2

func _ready() -> void:
	super._ready()
	animated_sprite_2d.play()


func _physics_process(delta: float) -> void:
	if !_is_player_in_room:
		return
	if sprint_direction == Vector2.ZERO:
		if down_ray_cast_2d.is_colliding():
			sprint_direction = Vector2.DOWN
		if left_ray_cast_2d.is_colliding():
			sprint_direction = Vector2.LEFT
		if right_ray_cast_2d.is_colliding():
			sprint_direction = Vector2.RIGHT
		if up_ray_cast_2d.is_colliding():
			sprint_direction = Vector2.UP
	
	if sprint_direction != Vector2.ZERO:
		var collide = move_and_collide(sprint_direction, true)
		if collide: sprint_direction = Vector2.ZERO
		else:
			velocity = sprint_direction * sprint_speed
			move_and_slide()
