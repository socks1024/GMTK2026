@abstract class_name Box
extends Entity

@export var push_distance: float = 80
@export var push_duration: float = 0.2
@export_flags_2d_physics var raycast_collision_mask: int = 163

var is_pushing: bool = false
var push_tween: Tween

func push_box(direction: Vector2) -> void:
	if is_pushing: return
	
	var target_pos: Vector2 = global_position + direction * push_distance
	
	if !can_push_to(target_pos):
		return
	
	is_pushing = true
	if push_tween: push_tween.kill()
	push_tween = create_tween()\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	push_tween.tween_property(self, "position", target_pos, push_duration)
	push_tween.tween_callback(func():is_pushing = false)


func can_push_to(target_pos: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.create(global_position, target_pos, raycast_collision_mask)
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	return !result


func destroy() -> void:
	pass
