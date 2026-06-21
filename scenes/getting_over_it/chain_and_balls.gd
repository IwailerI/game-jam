class_name ChainAndBalls
extends Node2D

const MAX_DIST := 50.0

@export var force_p: float = 100.0
@export var force_f: float = 100.0
@export var damage: int = 50

@onready var flail: RigidBody2D = $Flail
@onready var player: RigidBody2D = $Player
@onready var chain: Line2D = $Chain
@onready var health_component: HealthComponent = $HealthComponent
@onready var flail_hurt_box: Area2D = %HurtBox


static func get_instance() -> ChainAndBalls:
	var cnb: ChainAndBalls = (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"chain_and_balls")

	if cnb == null:
		push_error("no cnb :(")

	return cnb


func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.damaged.connect(_on_damaged)
	flail_hurt_box.body_entered.connect(_on_flail_enemy_entered)
	flail_hurt_box.area_entered.connect(_on_flail_enemy_entered)


func _physics_process(_delta: float) -> void:
	flail.freeze = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	player.freeze = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if player.freeze and not flail.freeze:
		player.linear_velocity = Vector2.ZERO
		var dist_origin_mouse := (get_global_mouse_position() - player.global_position).length()
		var target_pos: Vector2 = (get_global_mouse_position() - player.global_position).normalized() * min(dist_origin_mouse, MAX_DIST) + player.global_position
		flail.apply_central_force((target_pos - flail.global_position).normalized() * force_f)
	elif not player.freeze and flail.freeze:
		flail.linear_velocity = Vector2.ZERO
		player.apply_central_force((get_global_mouse_position() - player.global_position).normalized() * force_p)

	_apply_constaint()

	chain.points = PackedVector2Array([
		chain.to_local(player.global_position),
		chain.to_local(flail.global_position),
	])

	queue_redraw()

func _draw() -> void:
	if player.freeze and not flail.freeze:
		player.linear_velocity = Vector2.ZERO
		var dist_origin_mouse := (get_global_mouse_position() - player.global_position).length()
		var target_pos: Vector2 = (get_global_mouse_position() - player.global_position).normalized() * min(dist_origin_mouse, MAX_DIST) + player.global_position
		draw_line(to_local(player.global_position), to_local(target_pos), Color.ORANGE)
		draw_line(to_local(flail.global_position), to_local(target_pos), Color.LIME)


func _apply_constaint() -> void:
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


func _on_damaged(amount: int) -> void:
	print("player took ", amount, " damage")


func _on_died() -> void:
	print("game over")

func _on_flail_enemy_entered(enemy: Node2D) -> void:
	if not enemy or not enemy.has_method("apply_knockback") or not enemy.get("health_component"):
		return

	enemy.health_component.damage(damage)

	enemy.apply_knockback(flail.linear_velocity)
