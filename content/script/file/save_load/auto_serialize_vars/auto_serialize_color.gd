class_name AutoSerializeColor extends AutoSerializeVar
## Color 类型的自动序列化字段

func _init(section: String, key: String, default: Color, dispose_signal: Signal) -> void:
	super._init(section, key, default, dispose_signal)

var value: Color:
	get():
		return _cache
	set(v):
		if _cache == v:
			return
		_cache = v
		SaveServer.set_value(_section, _key, v)
		value_changed.emit(v)
