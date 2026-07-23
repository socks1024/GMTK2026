class_name Player
extends Character

signal key_count_changed(value: int)
signal money_count_changed(value: int)

static var instance: Player

@export_group("Data")
@export var speed: float = 100
@export var melee_damage: int = 4

@export_group("Ref")
@export var player_hud: PackedScene

var _key_count: int = 0
var key_count: int:
	get():
		return _key_count
	set(v):
		_key_count = maxi(0, v)
		if saved_key_count: saved_key_count.value = key_count
		key_count_changed.emit(_key_count)

var _money_count: int = 0
var money_count: int:
	get():
		return _money_count
	set(v):
		_money_count = maxi(0, v)
		if saved_money_count: saved_money_count.value = money_count
		money_count_changed.emit(_money_count)

var facing_direction: Vector2 = Vector2.RIGHT

var saved_position: AutoSerializeVector2
var saved_max_health: AutoSerializeInt
var saved_money_count: AutoSerializeInt
var saved_key_count: AutoSerializeInt

@onready var player_controller: PlayerController = $PlayerController


static func quick_get_player() -> Player:
	return instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	player_controller.facing_direction_changed.connect(
		func(v): facing_direction = v
	)
	
	#region SaveLoad
	saved_position = AutoSerializeVector2.new("Player","Pos",position,tree_exited)
	position = saved_position.value
	
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
	#endregion


func _physics_process(_delta: float) -> void:
	velocity = player_controller.move_direction * speed
	move_and_slide()
	saved_position.value = position


func is_living() -> bool:
	return health > 0


func _on_hit_box_area_entered(area: Area2D) -> void:
	var item: Entity = area.get_parent() as Entity
	if item: item.on_touched_by_player(self)


func _on_hit_box_body_entered(body: Node2D) -> void:
	var item: Entity = body.get_parent() as Entity
	if item: item.on_touched_by_player(self)


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	var item: Entity = body.get_parent() as Entity
	if item: item.on_hit_by_sword(facing_direction, self)
	
	var enemy: Enemy = body as Enemy
	CLog.o(enemy)
	if enemy:
		enemy.take_health_damage(melee_damage)
