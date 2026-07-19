class_name SaveMeta extends Resource
## 存档的元信息（每份存档一份，随 KV 一起持久化）

## 首次创建时间戳（Unix 秒），仅首次创建时写入
@export var created_time: int = 0
## 最近一次保存的时间戳（Unix 秒）
@export var modified_time: int = 0
## 已保存次数，UI 上展示"已保存 N 次"
@export var saved_count: int = 0
## 累计游戏时长（秒）
@export var play_time_seconds: int = 0
## 保存时的游戏版本号，外部会根据该版本号判断当前版本是否兼容此存档
@export var game_version: String = ""
## 玩家可见名称，UI 列表上展示用
@export var display_name: String = ""

func initialize(name: String) -> void:
	self.display_name = name
	self.created_time = int(Time.get_unix_time_from_system())
	update()


func update() -> void:
	self.saved_count += 1
	self.modified_time = int(Time.get_unix_time_from_system())
	self.game_version = ProjectSettings.get_setting("application/config/version", "")
	self.play_time_seconds = modified_time - self.created_time # 现在的计算方法是错误的
