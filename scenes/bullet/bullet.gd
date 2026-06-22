extends Area2D


@export var speed: float = 120
@export var damage: int = 10
@export var knockback: float = 100.0

@onready var cnb := ChainAndBalls.get_instance()
@onready var life_timer: Timer = $LifeTimer

var direction: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(queue_free)

	direction = global_position.direction_to(cnb.player.global_position)
	look_at(cnb.player.global_position)


func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(_area: Node2D) -> void:
	cnb.health_component.damage(damage)
	cnb.player.apply_central_impulse(global_position.direction_to(cnb.player.global_position) * knockback)
	queue_free()
