extends Enemy

@export var path_points: Array[Marker2D]
@export var move_speed: int = 100

var target_point: int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	super._ready()
	animated_sprite_2d.play()


func _physics_process(delta: float) -> void:
	if _is_player_in_room:
		if _get_displacement().length() < 1:
			target_point = (target_point + 1) % path_points.size()
		velocity = _get_displacement().normalized() * move_speed
		if velocity.x > 0: animated_sprite_2d.flip_h = true
		if velocity.x < 0: animated_sprite_2d.flip_h = false
		move_and_slide()


func _get_displacement() -> Vector2:
	return path_points[target_point].global_position - global_position
