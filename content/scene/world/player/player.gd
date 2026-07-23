class_name Player
extends CharacterBody2D

signal health_changed(value: int)
signal max_health_changed(value: int)
signal magic_changed(value: int)
signal max_magic_changed(value: int)
signal key_count_changed(value: int)
signal money_count_changed(value: int)

signal live_form_changed(is_living: bool)
signal player_dead

static var instance: Player

@export_group("Data")
@export var speed: float = 100
@export var default_max_health: int = 12
@export var default_max_magic: int = 9

@export_group("Ref")
@export var player_hud: PackedScene

var saved_position: AutoSerializeVector2

var _max_health: int = 1
var max_health: int:
	get():
		return _max_health
	set(v):
		_max_health = clampi(v, 1, 999)
		health = mini(max_health, health)
		if saved_max_health: saved_max_health.value = max_health
		max_health_changed.emit(max_health)
		if max_health <= 0:
			player_dead.emit()
var saved_max_health: AutoSerializeInt

var _health: int = 1
var health: int:
	get():
		return _health
	set(v):
		var last_health: int = health
		_health = clampi(v, 0, max_health)
		if saved_health: saved_health.value = health
		if last_health != health:
			health_changed.emit(health)
			if last_health == 0 && health > 0:
				live_form_changed.emit(true)
			elif last_health > 0 && health == 0:
				live_form_changed.emit(false)
var saved_health: AutoSerializeInt

var _max_magic: int = 1
var max_magic: int:
	get():
		return _max_magic
	set(v):
		_max_magic = clampi(v, 1, 999)
		magic = mini(max_magic, magic)
		if saved_max_magic: saved_max_magic.value = max_magic
		max_magic_changed.emit(max_magic)
var saved_max_magic: AutoSerializeInt

var _magic: int = 1
var magic: int:
	get():
		return _magic
	set(v):
		_magic = clampi(v, 0, max_magic)
		if saved_magic: saved_magic.value = magic
		magic_changed.emit(magic)
var saved_magic: AutoSerializeInt

var _key_count: int = 0
var key_count: int:
	get():
		return _key_count
	set(v):
		_key_count = maxi(0, v)
		if saved_key_count: saved_key_count.value = key_count
		key_count_changed.emit(_key_count)
var saved_key_count: AutoSerializeInt

var _money_count: int = 0
var money_count: int:
	get():
		return _money_count
	set(v):
		_money_count = maxi(0, v)
		if saved_money_count: saved_money_count.value = money_count
		money_count_changed.emit(_money_count)
var saved_money_count: AutoSerializeInt

var facing_direction: Vector2 = Vector2.RIGHT

@onready var player_controller: PlayerController = $PlayerController


static func quick_get_player() -> Player:
	return instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	player_controller.facing_direction_changed.connect(
		func(v): facing_direction = v
	)
	
	# Load
	saved_position = AutoSerializeVector2.new("Player","Pos",position,tree_exited)
	position = saved_position.value
	
	saved_max_health = AutoSerializeInt.new("Player","MaxHealth",default_max_health,tree_exited)
	max_health = saved_max_health.value
	
	saved_health = AutoSerializeInt.new("Player","Health",default_max_health,tree_exited)
	health = saved_health.value
	
	saved_max_magic = AutoSerializeInt.new("Player","MaxMagic",default_max_magic,tree_exited)
	max_magic = saved_max_magic.value
	
	saved_magic = AutoSerializeInt.new("Player","Magic",default_max_magic,tree_exited)
	magic = saved_magic.value
	
	saved_key_count = AutoSerializeInt.new("Player","KeyCount",0,tree_exited)
	key_count = saved_key_count.value
	
	saved_money_count = AutoSerializeInt.new("Player","MoneyCount",0,tree_exited)
	money_count = saved_money_count.value
	# Load
	
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


func _physics_process(_delta: float) -> void:
	velocity = player_controller.move_direction * speed
	move_and_slide()
	saved_position.value = position


func take_health_damage(damage: int) -> void:
	health -= damage


func take_max_health_damage(damage: int) -> void:
	max_health -= damage


func take_common_damage(damage: int) -> void:
	if damage <= health:
		take_health_damage(damage)
	else:
		var max_health_damage: int = damage - health
		take_health_damage(health)
		take_max_health_damage(max_health_damage)


func heal_health(amount: int) -> void:
	health += amount


func is_living() -> bool:
	return health > 0


func _on_hit_box_area_entered(area: Area2D) -> void:
	var item: MapItem = area.get_parent() as MapItem
	if item: item.touch_interact(self)


func _on_hit_box_body_entered(body: Node2D) -> void:
	var item: MapItem = body.get_parent() as MapItem
	if item: item.touch_interact(self)


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	var item: MapItem = body.get_parent() as MapItem
	if item: item.hit_interact(self)
	
	var enemy: Enemy = body as Enemy
	CLog.o(enemy)
	if enemy:
		enemy.take_health_damage(4)
		self.heal_health(4)
		CLog.o("hit enemy")
