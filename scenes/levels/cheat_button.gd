extends Button


func _pressed() -> void:
	Persistence.current_score = GameManager.last_level()
	Persistence.submit()

	print("You now have all levels unlocked")
