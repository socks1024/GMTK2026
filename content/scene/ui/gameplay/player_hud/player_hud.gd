extends StackableControl

@export var health_progress_bar: FeelProgressBar
@export var health_value: Label
@export var max_health_value: Label
#@export var magic_progress_bar: FeelProgressBar
#@export var magic_value: Label
#@export var max_magic_value: Label
@export var key_count: Label
@export var money_count: Label

var _player: Player
var _max_health_unit: float


func connect_to_player(player: Player):
	player.max_health_changed.connect(_on_player_max_health_changed)
	player.health_changed.connect(_on_player_health_changed)
	#player.max_magic_changed.connect(_on_player_max_magic_changed)
	#player.magic_changed.connect(_on_player_magic_changed)
	player.key_count_changed.connect(_on_player_key_count_changed)
	player.money_count_changed.connect(_on_player_money_count_changed)
	
	_max_health_unit = health_progress_bar.custom_minimum_size.x / player.max_health
	
	_player = player


func _on_player_max_health_changed(value: int):
	health_progress_bar.custom_minimum_size.x = max(value * _max_health_unit, _max_health_unit) 
	health_progress_bar.set_value(float(_player.health) / _player.max_health, false)
	max_health_value.text = str(value)

func _on_player_health_changed(value: int):
	health_progress_bar.set_value(float(_player.health) / _player.max_health, false)
	health_value.text = str(value)

#func _on_player_max_magic_changed(value: int):
	#magic_progress_bar.value = float(_player.magic) / _player.max_magic
	#max_magic_value.text = str(value)
#
#func _on_player_magic_changed(value: int):
	#magic_progress_bar.value = float(_player.magic) / _player.max_magic
	#magic_value.text = str(value)

func _on_player_key_count_changed(value: int):
	key_count.text = str(value)

func _on_player_money_count_changed(value: int):
	money_count.text = str(value)
	CLog.o(value)
