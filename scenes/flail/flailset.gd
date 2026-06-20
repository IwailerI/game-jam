class_name FlailSet
extends Node2D


const FLAIL_SCENE := preload("res://scenes/flail/flail_ball.tscn")

signal upgrade_done


func _physics_process(_delta: float) -> void:
	for child: Node in get_children():
		var fb := child as FlailBall
		if fb == null or fb.parent != null: continue

		fb.force_update_position()
