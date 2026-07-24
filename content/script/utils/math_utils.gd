class_name MathUtils


static func vector2_to_4_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		if vec.x > 0:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	else:
		if vec.y > 0:
			return Vector2.DOWN
		else:
			return Vector2.UP
