extends StackableControl

@onready var health_progress_bar: FeelProgressBar = $MarginContainer/VBoxContainer/Health/FeelProgressBar
@onready var health_value: Label = $MarginContainer/VBoxContainer/Health/FeelProgressBar/HBoxContainer/Value
@onready var max_health_value: Label = $MarginContainer/VBoxContainer/Health/FeelProgressBar/HBoxContainer/MaxValue
@onready var magic_progress_bar: FeelProgressBar = $MarginContainer/VBoxContainer/Magic/FeelProgressBar
@onready var magic_value: Label = $MarginContainer/VBoxContainer/Magic/FeelProgressBar/HBoxContainer2/Value
@onready var max_magic_value: Label = $MarginContainer/VBoxContainer/Magic/FeelProgressBar/HBoxContainer2/MaxValue
@onready var key_count: Label = $MarginContainer/VBoxContainer/KeyCount/Label

var _player: Player

func connect_to_player(player: Player):
	player.max_health_changed.connect(_on_player_max_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	player.max_magic_changed.connect(_on_player_max_magic_changed)
	player.magic_changed.connect(_on_player_magic_changed)
	player.key_count_changed.connect(_on_player_key_count_changed)
	
	_player = player


func _on_player_max_health_changed(value: int):
	health_progress_bar.value = float(_player.health) / _player.max_health
	max_health_value.text = str(value)

func _on_player_health_changed(value: int):
	health_progress_bar.value = float(_player.health) / _player.max_health
	health_value.text = str(value)

func _on_player_max_magic_changed(value: int):
	magic_progress_bar.value = float(_player.magic) / _player.max_magic
	max_magic_value.text = str(value)

func _on_player_magic_changed(value: int):
	magic_progress_bar.value = float(_player.magic) / _player.max_magic
	magic_value.text = str(value)

func _on_player_key_count_changed(value: int):
	key_count.text = str(value)
