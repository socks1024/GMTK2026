class_name AutoSerializeInt extends AutoSerializeVar
## int 类型的自动序列化字段

func _init(section: String, key: String, default: int, dispose_signal: Signal) -> void:
	super._init(section, key, default, dispose_signal)

var value: int:
	get():
		return _cache
	set(v):
		if _cache == v:
			return
		_cache = v
		SaveServer.set_value(_section, _key, v)
		value_changed.emit(v)
