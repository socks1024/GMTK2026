class_name Door
extends MapItem

@onready var sprite: Sprite2D = $Sprite
@onready var static_body_2d: StaticBody2D = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func open() -> void:
	sprite.hide()
	static_body_2d.process_mode = Node.PROCESS_MODE_DISABLED


func interact(player: Player) -> void:
	if player.key_count > 0:
		open()
		player.key_count -= 1
