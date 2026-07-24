extends HBoxContainer

@export var heart_textures: Array[Texture2D]

var heart_rects: Array[TextureRect]


func _ready() -> void:
	for n in get_children():
		if n is TextureRect:
			heart_rects.append(n)


func update_hearts(health: int, max_health: int) -> void:
	for i in heart_rects.size():
		if max_health / 4 > i:
			heart_rects[i].show()
			heart_rects[i].texture = heart_textures[clamp(health - i * 4, 0, 4)]
		else:
			heart_rects[i].hide()
