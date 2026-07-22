class_name MagicMissile
extends Node2D

var damage: int = 4
var speed: float = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).take_health_damage(damage)
	queue_free.call_deferred()
