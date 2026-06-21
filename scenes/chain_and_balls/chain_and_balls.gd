class_name ChainAndBalls
extends Node2D

const _GROUNDED_FLAIL := preload("res://scenes/chain_and_balls/grounded_flail_ball.tscn")

@export var force_p: float = 100.0
@export var force_f: float = 100.0

var _prev_flail_grounded: bool = false
var _last_grounded_flail: Sprite2D

@onready var flail: RigidBody2D = $Flail
@onready var player: RigidBody2D = $Player
@onready var chain: Line2D = $Chain
@onready var health_component: HealthComponent = $HealthComponent


static func get_instance() -> ChainAndBalls:
	var cnb: ChainAndBalls = (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"chain_and_balls")

	if cnb == null:
		push_error("no cnb :(")

	return cnb


func _physics_process(_delta: float) -> void:
	flail.freeze = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var flail_frozen_delta := int(flail.freeze) - int(_prev_flail_grounded)
	_prev_flail_grounded = flail.freeze
	player.freeze = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if player.freeze and not flail.freeze:
		player.linear_velocity = Vector2.ZERO
		flail.apply_central_force((get_global_mouse_position() - flail.global_position).normalized() * force_f)
	elif not player.freeze and flail.freeze:
		flail.linear_velocity = Vector2.ZERO
		player.apply_central_force((get_global_mouse_position() - player.global_position).normalized() * force_p)

	_apply_constaint()

	chain.points = PackedVector2Array([
		chain.to_local(player.global_position),
		chain.to_local(flail.global_position),
	])

	match flail_frozen_delta:
		1: # just landed
			if is_instance_valid(_last_grounded_flail):
				_last_grounded_flail.queue_free()
			_last_grounded_flail = _GROUNDED_FLAIL.instantiate()
			_last_grounded_flail.global_position = flail.global_position
			flail.hide()
			add_child(_last_grounded_flail)
		-1: # just released
			if is_instance_valid(_last_grounded_flail):
				_last_grounded_flail.frame = 0
				var t := _last_grounded_flail.create_tween().chain()
				t.tween_interval(2.0)
				t.tween_property(_last_grounded_flail, "modulate:a", 0.0, 0.5)
				t.tween_callback(_last_grounded_flail.queue_free)
				_last_grounded_flail = null
			flail.show()


func _apply_constaint() -> void:
	const MAX_DIST := 50.0

	var delta := flail.global_position - player.global_position
	var delta_len := delta.length()

	if delta_len <= MAX_DIST:
		return

	var dir := delta / delta_len
	var error := delta_len - MAX_DIST

	var p_bias: float = 0.5

	if player.freeze and not flail.freeze:
		p_bias = 0
	elif not player.freeze and flail.freeze:
		p_bias = 1

	player.global_position += dir * error * p_bias
	flail.global_position -= dir * error * (1 - p_bias)

	var rel_vel := (flail.linear_velocity - player.linear_velocity).dot(dir)
	if rel_vel <= 0:
		return

	var inv_mass_sum := 1.0 / player.mass + 1.0 / flail.mass

	var impulse_mag := -rel_vel / inv_mass_sum
	var impulse := dir * impulse_mag

	player.apply_impulse(-impulse * p_bias)
	flail.apply_impulse(impulse * (1 - p_bias))
