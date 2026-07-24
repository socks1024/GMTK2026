extends Enemy

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	sprite_2d.play()
