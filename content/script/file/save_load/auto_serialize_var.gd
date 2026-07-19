@abstract class_name AutoSerializeVar extends RefCounted
## 自动序列化字段的基类（抽象类，不直接使用）
##
## 每一个具体的 AutoSerializeVar 子类负责一种类型（Int/Bool/Float 等），
## 通过 section + key 定位到 SaveServer 里的一个存档字段，
## 子类实现 value 的 get/set 来承载具体的读写与缓存逻辑。
## 
## 后续若换到 C# 等具有原生强类型泛型的语言，可以将 AutoSerializeVar 改为泛型类。
## 后续若切换到 C# 等具有弱引用的语言，可以将主动连接销毁信号改为通过弱引用的信号连接自动销毁。

## 当前值发生变化时触发
signal value_changed(new_value: Variant)

## 该字段在存档中的段名
var _section: String

## 该字段在存档中的键名
var _key: String

## 该字段在存档中不存在时的默认值
var _default: Variant

## 当前缓存的值
var _cache: Variant

## 宿主传入的销毁信号，触发后本对象会断开信号连接
var _dispose_signal: Signal

func _init(section: String, key: String, default: Variant, dispose_signal: Signal) -> void:
	_section = section
	_key = key
	_default = default
	_dispose_signal = dispose_signal

	_cache = SaveServer.get_value(_section, _key, _default) if SaveServer._cached_save != null else _default

	SaveServer.loaded.connect(_on_save_loaded)
	_dispose_signal.connect(_dispose)

func has_value() -> bool:
	return SaveServer.has_value(_section, _key)

func erase_value() -> void:
	SaveServer.erase_value(_section, _key)

## 存档加载完成时刷新缓存，并在值发生变化时抛出 value_changed
func _on_save_loaded() -> void:
	var new_value: Variant = SaveServer.get_value(_section, _key, _default)
	if new_value == _cache:
		return
	_cache = new_value
	value_changed.emit(_cache)

## 宿主销毁时断开所有信号连接
func _dispose() -> void:
	if SaveServer.loaded.is_connected(_on_save_loaded):
		SaveServer.loaded.disconnect(_on_save_loaded)
	if _dispose_signal.is_connected(_dispose):
		_dispose_signal.disconnect(_dispose)
