extends StackableControl

@export var hearts: HBoxContainer
@export var keys: HBoxContainer

var _player: Player

@onready var countdown: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Countdown

func connect_to_player(player: Player):
	player.max_health_changed.connect(_on_player_max_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	player.key_count_changed.connect(_on_player_key_count_changed)
	
	_player = player

func _process(delta: float) -> void:
	var minutes = _player.live_timer.time_left / 60
	var seconds = int(_player.live_timer.time_left) % 60
	countdown.text = "%02d:%02d" % [minutes, seconds]

func _on_player_max_health_changed(value: int):
	hearts.update_hearts(_player.health, _player.max_health)

func _on_player_health_changed(value: int):
	hearts.update_hearts(_player.health, _player.max_health)

func _on_player_key_count_changed(value: int):
	keys.update_key_count(value)
