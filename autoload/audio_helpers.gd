extends Node

@onready var explosion_audio_stream_player: AudioStreamPlayer = $ExplosionAudioStreamPlayer
@onready var click_audio_stream_player: AudioStreamPlayer = $ClickAudioStreamPlayer
@onready var victory_audio_stream_player: AudioStreamPlayer = $VictoryAudioStreamPlayer
@onready var music_audio_stream_player: AudioStreamPlayer = $MusicAudioStreamPlayer

func _ready() -> void:
	music_audio_stream_player.finished.connect(_on_music_finished)

func play_building_destruction() -> void:
	explosion_audio_stream_player.play()

func register_buttons(butons: Array[Button]) -> void:
	for button in butons:
		button.pressed.connect(self._on_button_pressed)

func _on_button_pressed() -> void:
	click_audio_stream_player.play()

func play_victory() -> void:
	victory_audio_stream_player.play()

func _on_music_finished() -> void:
	get_tree().create_timer(5).timeout.connect(_on_music_delay_timer_timeout)

func _on_music_delay_timer_timeout() -> void:
	music_audio_stream_player.play()
