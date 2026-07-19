extends Node
## 游戏存档的 KV 存取层（autoload 单例）
##
## 与 ConfigServer 定位不同：ConfigServer 管理用户设置（分辨率、音量等），
## SaveServer 管理游戏存档数据（玩家数据、关卡进度等），支持多槽位。

## 存档加载完成后触发（create 成功进入加载路径时也会触发）
signal loaded

## 存档文件扩展名
const SAVE_EXT: String = ".save"
## 元信息在 ConfigFile 中的专用段名/键名
const META_SECTION: String = "SaveMeta"
const META_KEY: String = "SaveMeta"

## 存档文件目录
var _save_dir: String = "user://saves/"
var save_dir: String:
	get():
		if !DirAccess.dir_exists_absolute(_save_dir):
			var e = DirAccess.make_dir_recursive_absolute(_save_dir)
			if e != OK:
				CLog.e("Failed to ensure save dir, error:", e)
		return _save_dir

## 当前已加载的槽位标识
var current_slot_id: String = ""
## 本次运行内的加载次数
var load_count: int = 0

## 内部持有的 ConfigFile，承载当前存档的数据
var _cached_save: ConfigFile = null
## 当前存档的元信息的缓存
var _cached_save_meta: SaveMeta = null

#region AutoSerializeAPI

## 检查是否存在某个设置项
func has_value(section: String, key: String) -> bool:
	if _cached_save == null:
		return false
	return _cached_save.has_section_key(section, key)

## 从存档对象读取数据
func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if _cached_save == null:
		return default
	return _cached_save.get_value(section, key, default)

## 向存档对象写入数据
func set_value(section: String, key: String, value: Variant) -> void:
	if _cached_save == null:
		return
	_cached_save.set_value(section, key, value)

## 从存档对象删除数据
func erase_value(section: String, key: String) -> void:
	if has_value(section, key):
		_cached_save.erase_section_key(section, key)

#endregion

## 获取指定槽位的存档路径
func get_save_path(slot_id: String) -> String:
	return save_dir + slot_id + SAVE_EXT

## 检查是否存在某个槽位
func is_save_exists(slot_id: String) -> bool:
	return FileAccess.file_exists(get_save_path(slot_id))


## 创建新存档并写入磁盘
func create_new_save(slot_id: String, display_name: String = "") -> void:
	# 不能在已存在的槽位上创建新存档
	if is_save_exists(slot_id):
		CLog.w("Create new save ignored: Slot already exists")
		return

	# 清空内存状态，准备新存档
	var save = ConfigFile.new()
	
	# 初始化元数据
	var meta = SaveMeta.new()
	meta.initialize(display_name)
	save.set_value(META_SECTION, META_KEY, meta)
	
	var e: Error = save.save(get_save_path(slot_id))
	if e != OK:
		CLog.e("Failed to create new save at slot:", slot_id, ", error:", e)
		return
	
	CLog.o("New save created at slot:", slot_id)

## 从磁盘加载指定槽位的存档到内存中
func load_from_slot(slot_id: String) -> void:
	# 检查是否存在指定槽位的存档
	if !is_save_exists(slot_id):
		CLog.w("Load from slot ignored: Slot does not exist")
		return
	
	var cf: ConfigFile = ConfigFile.new()
	var e: Error = cf.load(get_save_path(slot_id))
	if e != OK:
		# 文件不存在或读取失败
		CLog.e("Failed to load slot:", slot_id)
		return
	
	_cached_save = cf
	_cached_save_meta = _cached_save.get_value(META_SECTION, META_KEY, null)
	CLog.o("Slot loaded:", slot_id)

	current_slot_id = slot_id
	load_count += 1
	loaded.emit()

## 将内存中的存档对象写入磁盘的指定槽位
func save_to_slot(slot_id: String) -> void:
	if _cached_save == null:
		CLog.w("Save to slot ignored: No save loaded")
		return
	
	if is_save_exists(slot_id):
		CLog.w("Overwriting slot:", slot_id)

	# 更新元数据
	_cached_save_meta.update()
	_cached_save.set_value(META_SECTION, META_KEY, _cached_save_meta)
	
	var e: Error = _cached_save.save(get_save_path(slot_id))
	if e != OK:
		CLog.e("Failed to save slot:", slot_id, "error:", e)
		return
	
	CLog.o("Slot saved:", slot_id)

## 将内存中的存档对象写入磁盘
func quick_save_to_curr_slot() -> void:
	if current_slot_id.is_empty():
		CLog.w("Save to current slot ignored: No save loaded")
		return
	save_to_slot(current_slot_id)

## 从内存中卸载存档
func unload() -> void:
	_cached_save = null
	_cached_save_meta = null
	current_slot_id = ""
	load_count += 1


## 只读取指定槽位的元信息，不加载 KV（存档列表页用）
func peek_meta(slot_id: String) -> SaveMeta:
	# 检查是否存在指定槽位的存档
	if !is_save_exists(slot_id):
		CLog.w("Peek meta ignored: Slot does not exist")
		return null
	
	var cf: ConfigFile = ConfigFile.new()
	var e: Error = cf.load(get_save_path(slot_id))
	if e != OK:
		CLog.e("Peek meta failed for slot:", slot_id, "error:", e)
		return null
	
	var loaded_meta: Variant = cf.get_value(META_SECTION, META_KEY, null)
	return loaded_meta if loaded_meta is SaveMeta else null

## 删除指定槽位的存档文件
func delete_slot(slot_id: String) -> void:
	var e: Error = DirAccess.remove_absolute(get_save_path(slot_id))
	if e != OK:
		CLog.e("Failed to delete slot:", slot_id, "error:", e)
		return
	
	CLog.o("Slot deleted:", slot_id)

## 列出存档目录下所有的槽位标识（按文件名字典序）
func list_slots() -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	
	var files: PackedStringArray = DirAccess.get_files_at(save_dir)
	for file_name: String in files:
		if file_name.ends_with(SAVE_EXT):
			result.append(file_name.get_basename())
	return result
