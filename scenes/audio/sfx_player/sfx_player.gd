class_name SfxPlayer
extends Node2D


@export var audio_streams: Dictionary[String, AudioStream]

var players: Dictionary[String, AudioStreamPlayer2D]
var time_left_to_finish_all: float = 0
var prepared_to_die: bool = false

func _ready() -> void:
	var player_tmpl := $AudioStreamPlayer2D

	remove_child(player_tmpl)

	for key: String in audio_streams.keys():
		var player: AudioStreamPlayer2D = player_tmpl.duplicate()
		players[key] = player
		player.name = key
		player.stream = audio_streams[key]
		add_child(player)


func _physics_process(delta: float) -> void:
	time_left_to_finish_all = max(0, time_left_to_finish_all - delta)


# returns the played audio stream
func play_sound(key: String) -> AudioStream:
	if key not in audio_streams:
		push_error("unknown key: '%s'" % key)
		return null

	var player := players[key]
	var stream := audio_streams[key]

	player.play()
	time_left_to_finish_all = max(time_left_to_finish_all, stream.get_length())

	return stream


func prepare_to_die() -> void:
	if prepared_to_die:
		return

	prepared_to_die = true

	var grandparent := get_parent().get_parent()
	get_parent().remove_child(self)
	grandparent.add_child(self)

	var t := create_tween()
	t.tween_interval(time_left_to_finish_all)
	t.tween_callback(queue_free)
