## invariant: parent must be initialized and ready or null

class_name FlailBall
extends Node2D


signal position_updated

@export var rotation_speed: float = PI
@export var starting_rotation_angle: float = 0.0
@export var radius: float
@export var parent: FlailBall
@export var damage: int = 50

var _rotation_angle: float = 0.0
var _is_selected: bool = false

@onready var _line: Line2D = $Line2D
@onready var _sprite: Sprite2D = $Sprite2D

@onready var hurt_box: Area2D = $HurtBox


func _ready() -> void:
	_rotation_angle = starting_rotation_angle


	if parent != null:
		hurt_box.body_entered.connect(_on_enemy_entered)
		hurt_box.area_entered.connect(_on_enemy_entered)

		if parent.is_node_ready():
			parent.position_updated.connect(_update_position)
		else:
			(func () -> void:
				if not parent.is_node_ready():
					await parent.ready
				parent.position_updated.connect(_update_position)
			).call_deferred()
	else:
		_sprite.hide()
		_line.hide()


func _physics_process(_delta: float) -> void:
	if parent == null:
		position_updated.emit()


func _update_position() -> void:
	if not is_instance_valid(parent):
		position_updated.emit()
		return

	var delta: float = get_physics_process_delta_time()
	_rotation_angle += delta * rotation_speed
	_rotation_angle = fposmod(_rotation_angle, TAU)

	global_position = parent.global_position + Vector2.from_angle(_rotation_angle) * radius
	_line.points = PackedVector2Array([Vector2.ZERO, to_local(parent.global_position)])

	_sprite.look_at(parent.global_position)

	position_updated.emit()


func force_update_position() -> void:
	_update_position()


func _on_enemy_entered(enemy: Node2D) -> void:
	if not enemy or not enemy.has_method("apply_knockback") or not enemy.get("health_component"):
		return

	enemy.health_component.damage(damage)

	var vel := _get_head_direction()
	var lin_vel := rotation_speed * radius
	enemy.apply_knockback(vel * lin_vel)


func _get_head_direction() -> Vector2:
	return Vector2.from_angle(_rotation_angle + TAU / 4 * signf(rotation_speed))


func set_selected(v: bool) -> void:
	_is_selected = v
	queue_redraw()


func _draw() -> void:
	if not _is_selected:
		return

	draw_circle(Vector2.ZERO, 16, Color.BLUE, false)
