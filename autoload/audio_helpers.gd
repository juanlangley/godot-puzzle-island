extends Node

@onready var explosion_audio_stream_player: AudioStreamPlayer = $ExplosionAudioStreamPlayer

func _ready() -> void:
	pass

func play_building_destruction() -> void:
	explosion_audio_stream_player.play()
