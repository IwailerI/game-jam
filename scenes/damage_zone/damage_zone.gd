extends Node2D

const RADIUS: float = 64.0

@export var damage: int = 5
@export var damage_interval: float = 0.75
@export var lifetime: float = 5

@export_flags_2d_physics var mask: int = 1

@onready var _ttl: float = lifetime
@onready var _time_to_tick: float = damage_interval

func _physics_process(delta: float) -> void:
	_ttl -= delta
	_time_to_tick -= delta

	if _time_to_tick <= 0:
		_do_damage()
		_time_to_tick += damage_interval

	if _ttl <= 0:
		queue_free()

func _do_damage() -> void:
	var params := PhysicsShapeQueryParameters2D.new()

	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = mask

	var cirlce := CircleShape2D.new()
	cirlce.radius = RADIUS
	params.shape = cirlce

	params.transform.origin = global_position

	var cnb := ChainAndBalls.get_instance()

	for col: Dictionary in get_world_2d().direct_space_state.intersect_shape(params, 2):
		if col.collider == cnb.player:
			cnb.health_component.damage(damage)
