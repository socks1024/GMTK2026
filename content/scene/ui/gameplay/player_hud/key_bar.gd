extends HBoxContainer

var key_rects: Array[TextureRect]


func _ready() -> void:
	for n in get_children():
		if n is TextureRect:
			key_rects.append(n)


func update_key_count(count: int) -> void:
	for i in key_rects.size():
		if i < count: key_rects[i].show()
		else: key_rects[i].hide()
