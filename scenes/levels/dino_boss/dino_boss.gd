extends Node2D


@onready var boss_camera: Camera2D = %Camera


func _ready() -> void:
	boss_camera.make_current()
