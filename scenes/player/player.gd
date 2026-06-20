class_name Player
extends CharacterBody2D


@export var speed: float = 150.0
@export var acceleration: float = 1800.0


@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.damaged.connect(_on_damaged)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = velocity.move_toward(input_dir * speed, acceleration * delta)

	move_and_slide()


func _on_damaged(amount: int) -> void:
	print("player took ", amount, " damage")


func _on_died() -> void:
	print("game over")
