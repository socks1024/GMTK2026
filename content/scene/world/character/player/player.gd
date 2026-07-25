class_name Player
extends Character

signal key_count_changed(value: int)
signal money_count_changed(value: int)
signal revive_position_changed(value: Vector2)
signal max_live_time_changed(value: float)

signal get_hurt

static var instance: Player

@export_group("Data")
@export var speed: float = 100
@export var melee_damage: int = 4
@export var default_max_live_time = 30

@export_group("Others")
@export var player_hud: PackedScene
@export var invincible: bool = false

var _key_count: int = 0
var key_count: int:
	get():
		return _key_count
	set(v):
		_key_count = maxi(0, v)
		key_count_changed.emit(_key_count)

var _money_count: int = 0
var money_count: int:
	get():
		return _money_count
	set(v):
		_money_count = maxi(0, v)
		money_count_changed.emit(_money_count)

var _revive_position: Vector2 = Vector2.ZERO
var revive_position: Vector2:
	get():
		return _revive_position
	set(v):
		_revive_position = v
		revive_position_changed.emit(_revive_position)

var _max_live_time: float = 0
var max_live_time: float:
	get():
		return _max_live_time
	set(v):
		_max_live_time = max(v,0)
		max_live_time_changed.emit(_max_live_time)

var saved_max_health: AutoSerializeInt
var saved_money_count: AutoSerializeInt
var saved_key_count: AutoSerializeInt
var saved_revive_position: AutoSerializeVector2
var saved_max_live_time: AutoSerializeFloat

@onready var player_controller: PlayerController = $PlayerController
@onready var live_timer: Timer = $LiveTimer

static func quick_get_player() -> Player:
	return instance


func on_player_dead() -> void:
	get_tree().create_timer(0.45).timeout.connect(
		func():
			global_position = revive_position
			health = max_health
			live_timer.start(max_live_time)
	)


func gain_live_time(value: float) -> void:
	max_live_time += value
	live_timer.start(live_timer.time_left + value)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	live_timer.timeout.connect(
		func(): take_health_damage(9999)
	)
	
	character_dead.connect(on_player_dead)
	
	#region SaveLoad
	saved_revive_position = AutoSerializeVector2.new("Player","RevivePosition",position,tree_exited)
	revive_position = saved_revive_position.value
	position = revive_position
	revive_position_changed.connect(func(v):saved_revive_position.value = v)
	
	saved_max_health = AutoSerializeInt.new("Player","MaxHealth",default_max_health,tree_exited)
	max_health = saved_max_health.value
	health = max_health
	max_health_changed.connect(func(v):saved_max_health.value = v)
	
	saved_key_count = AutoSerializeInt.new("Player","KeyCount",0,tree_exited)
	key_count = saved_key_count.value
	key_count_changed.connect(func(v):saved_key_count.value = v)
	
	saved_money_count = AutoSerializeInt.new("Player","MoneyCount",0,tree_exited)
	money_count = saved_money_count.value
	money_count_changed.connect(func(v):saved_money_count.value = v)
	
	saved_max_live_time = AutoSerializeFloat.new("Player","MaxLiveTime",default_max_live_time,tree_exited)
	max_live_time = saved_max_live_time.value
	max_live_time_changed.connect(func(v):saved_max_live_time.value = v)
	#endregion
	
	#region Command
	var hud: StackableControl = player_hud.instantiate()
	UIStackManager.push(hud, "hud")
	hud.connect_to_player(self)
	self.tree_exited.connect(UIStackManager.pop.bind("hud")) #感觉这样后面会出问题，不过先这样吧
	
	Console.register("gain_key", func(amount:int):key_count += amount)\
		.arg("amount", TYPE_INT)\
		.info("gain small keys by given amount.")
	
	Console.register("gain_max_health", func(amount:int):max_health += amount)\
		.arg("amount", TYPE_INT)\
		.info("gain max_health by given amount.")
	
	Console.register("gain_health", func(amount:int):health += amount)\
		.arg("amount", TYPE_INT)\
		.info("gain health by given amount.")
	
	Console.register("gain_live_time", func(amount:float):gain_live_time(amount))\
		.arg("amount", TYPE_FLOAT)\
		.info("gain live time by given amount.")
	
	Console.register("godmode", func():
			key_count += 99
			max_health = 100
			health = max_health
			gain_live_time(3600)
			invincible = true
			)\
		.info("GOD MODE!!!")
	#endregion
	
	live_timer.start(max_live_time)


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_R):
		take_health_damage(9999)


func _on_hit_box_area_entered(area: Area2D) -> void:
	var item: Entity = area.get_parent() as Entity
	if item: item.on_touched_by_player(self)


func _on_hit_box_body_entered(body: Node2D) -> void:
	var item: Entity = body.get_parent() as Entity
	if item: item.on_touched_by_player(self)


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	var item: Entity = body.get_parent() as Entity
	if item: item.on_hit_by_sword(player_controller.facing_direction, self)
	
	var enemy: Enemy = body as Enemy
	if enemy:
		enemy.take_health_damage(melee_damage)


func take_health_damage(amount: int, knock_back: Vector2 = Vector2.ZERO) -> void:
	if !invincible:
		super.take_health_damage(amount)
		get_hurt.emit()
		var push_tween = create_tween()\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)\
			.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		push_tween.tween_property(self, "global_position", global_position + knock_back * 40, 0.3)
