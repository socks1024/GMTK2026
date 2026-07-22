class_name MapRegion 
extends MapItem

@onready var area_2d: Area2D = $Area2D

var map_tiles: TileMapLayer

var is_unlocked: AutoSerializeBool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_unlocked = AutoSerializeBool.new("MapRegion",name,false,tree_exited)
	unlock_region(is_unlocked.value)
	
	for node in get_children():
		if node is TileMapLayer:
			map_tiles = node
	
	for node in area_2d.get_children():
		node.queue_free()
	
	if map_tiles == null:
		CLog.w("MapRegion下没有放置TileMapLayer！")
	else:
		var tile_size: Vector2 = Vector2(
			map_tiles.tile_set.tile_size.x * map_tiles.scale.x, 
			map_tiles.tile_set.tile_size.y * map_tiles.scale.y)
		
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = tile_size
		
		for coord in map_tiles.get_used_cells():
			var collision: CollisionShape2D = CollisionShape2D.new()
			collision.shape = shape
			area_2d.add_child(collision)
			collision.position = Vector2(
				coord.x * tile_size.x + tile_size.x * 0.5,
				coord.y * tile_size.y + tile_size.y * 0.5)


func unlock_region(is_unlock: bool) -> void:
	is_unlocked.value = is_unlock
	if is_unlock:
		self.hide()


func touch_interact(player: Player) -> void:
	unlock_region(true)


func hit_interact(player: Player) -> void:
	unlock_region(true)