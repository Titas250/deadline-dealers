extends Control

# SCRUM-274: Kazino tematikos fonas
# SCRUM-275: Stilingi žaidimų mygtukai
# SCRUM-276: Animuotas pavadinimas
# SCRUM-277: Balanso rodymas

@onready var title_label: Label = $Title
@onready var game_buttons: HBoxContainer = $GameButtonsContainer
@onready var background: ColorRect = $Background
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

var _balance_label: Label

func _ready() -> void:
	_style_background()
	_setup_balance_label()
	_animate_title()
	_animate_buttons()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)

func _on_bgm_finished() -> void:
	bgm_player.play()

func _style_background() -> void:
	if not background:
		return
	# Tamsus kazino fonas su šviesesniu centru
	background.color = Color(0.05, 0.05, 0.08)

func _setup_balance_label() -> void:
	_balance_label = Label.new()
	_balance_label.name = "BalanceLabel"
	add_child(_balance_label)
	_balance_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_balance_label.offset_left = -220.0
	_balance_label.offset_right = -20.0
	_balance_label.offset_top = 18.0
	_balance_label.offset_bottom = 52.0
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_balance_label.add_theme_font_size_override("font_size", 22)
	_balance_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	if BalanceManager:
		_balance_label.text = "$ " + str(BalanceManager.get_balance())

func _animate_title() -> void:
	if not title_label:
		return
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title_label.modulate.a = 0.0
	title_label.pivot_offset = title_label.size / 2.0
	title_label.scale = Vector2(0.6, 0.6)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.8).set_delay(0.1)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)\
		.set_delay(0.1)

func _animate_buttons() -> void:
	if not game_buttons:
		return
	var delay := 0.4
	for btn in game_buttons.get_children():
		if not btn is Button:
			continue
		var button := btn as Button
		button.modulate.a = 0.0
		var original_y = button.position.y
		button.position.y += 40.0
		var tw = create_tween().set_parallel(true)
		tw.tween_property(button, "modulate:a", 1.0, 0.5).set_delay(delay)
		tw.tween_property(button, "position:y", original_y, 0.5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BACK)\
			.set_delay(delay)
		delay += 0.15

func _on_balance_changed(new_balance: int) -> void:
	if _balance_label:
		_balance_label.text = "$ " + str(new_balance)

func _on_game_one_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Blackjack/Blackjack.tscn")

func _on_game_two_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Roulette/Roulette.tscn")

func _on_settings_pressed() -> void:
	pass

func _on_stats_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/Stats/Stats.tscn")
