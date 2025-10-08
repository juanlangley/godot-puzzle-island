extends CanvasLayer
class_name OptionsMenu

@onready var sfx_down_button: Button = %SFXDownButton
@onready var sfx_label: Label = %SFXLabel
@onready var sfx_up_button: Button = %SFXUpButton
@onready var music_down_button: Button = %MusicDownButton
@onready var music_label: Label = %MusicLabel
@onready var music_up_button: Button = %MusicUpButton
@onready var window_button: Button = %WindowButton
@onready var back_button: Button = %BackButton
const SFX_BUS_NAME: String = "SFX"
const MUSIC_BUS_NAME: String = "Music"

signal back_to_menu_signal()

func _ready() -> void:
	var buttons: Array[Button] = [sfx_down_button, sfx_up_button, music_down_button, music_up_button, window_button, back_button]
	AudioHelpers.register_buttons(buttons)
	update_display()

func change_bus_volume(bus_name: String, change: float) -> void:
	var bus_volume_percent = OptionsHelper.get_bus_volume_percent(bus_name)
	bus_volume_percent = clampf(bus_volume_percent + change, 0, 1)
	OptionsHelper.set_bus_volume_percent(bus_name, bus_volume_percent)
	update_display()

func update_display() -> void:
	sfx_label.text = "%d" % roundf(OptionsHelper.get_bus_volume_percent(SFX_BUS_NAME)*10)
	music_label.text = "%d" % roundf(OptionsHelper.get_bus_volume_percent(MUSIC_BUS_NAME)*10)
	if OptionsHelper.is_full_screen():
		window_button.text = "Fullscreen"
	else:
		window_button.text = "Windowed"



func _on_sfx_up_button_pressed() -> void:
	change_bus_volume(SFX_BUS_NAME, 0.1)

func _on_sfx_down_button_pressed() -> void:
	change_bus_volume(SFX_BUS_NAME, -0.1)

func _on_music_up_button_pressed() -> void:
	change_bus_volume(MUSIC_BUS_NAME, 0.1)

func _on_music_down_button_pressed() -> void:
	change_bus_volume(MUSIC_BUS_NAME, -0.1)

func _on_window_button_pressed() -> void:
	update_display()
	OptionsHelper.toggle_window_mode()

func _on_back_button_pressed() -> void:
	back_to_menu_signal.emit()
