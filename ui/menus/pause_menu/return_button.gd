extends BetterButton


func _on_press() -> void:
	Transition.change_scene_path('res://ui/menus/main_menu/main_menu.tscn')
