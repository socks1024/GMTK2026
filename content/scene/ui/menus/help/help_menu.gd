extends StackableControl
## 游戏帮助/说明界面。
## 作为独立的 StackableControl 通过 UIStackManager 管理。


## 返回上一级菜单
func _on_back_anim_finish() -> void:
	_pop_related_layer()
