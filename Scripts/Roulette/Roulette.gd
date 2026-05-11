extends Control

# SCRUM-283: Vizualus ruletės rato komponentas
# SCRUM-284: Rato sukimosi animacija
# SCRUM-285: Statymų skaičių lentelė (grid)
# SCRUM-286: Animuotas rezultato rodymas

@onready var balance_label: Label = $BalanceLabel
@onready var spin_button: Button = $SpinButton
@onready var result_label: Label = $ResultLabel
@onready var back_button: Button = $BackButton
@onready var bet_red_button: Button = $BetRedButton
@onready var bet_black_button: Button = $BetBlackButton
@onready var number_bet_input: SpinBox = $NumberBetInput
@onready var confirm_number_button: Button = $ConfirmNumberBetButton
@onready var winning_number_label: Label = $WinningNumberLabel
@onready var bet_amount_spinbox: SpinBox = $BetAmountSpinBox
@onready var new_round_button: Button = $NewRoundButton

var winning_number: int = -1
var bet_type: String = ""
var chosen_number: int = -1
var current_bet: int = 0
var red_numbers: Array = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]
var black_numbers: Array = [2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35]

# Vizualiniai elementai
var _wheel_image: TextureRect
var _number_grid: GridContainer
var _selected_number_btn: Button = null

func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)
	if bet_amount_spinbox:
		bet_amount_spinbox.max_value = BalanceManager.get_balance()

	_setup_wheel()
	_setup_number_grid()

	# Paslėpk seną number input
	if number_bet_input: number_bet_input.visible = false
	if confirm_number_button: confirm_number_button.visible = false
	if has_node("NumberBetLabel"): $NumberBetLabel.visible = false

	# Signalai
	if bet_red_button and not bet_red_button.pressed.is_connected(_on_bet_red_button_pressed):
		bet_red_button.pressed.connect(_on_bet_red_button_pressed)
	if bet_black_button and not bet_black_button.pressed.is_connected(_on_bet_black_button_pressed):
		bet_black_button.pressed.connect(_on_bet_black_button_pressed)
	if spin_button and not spin_button.pressed.is_connected(_on_spin_button_pressed):
		spin_button.pressed.connect(_on_spin_button_pressed)
	if back_button and not back_button.pressed.is_connected(_on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)
	if new_round_button:
		new_round_button.visible = false
		if not new_round_button.pressed.is_connected(_on_new_round_pressed):
			new_round_button.pressed.connect(_on_new_round_pressed)

# ── Ruletės ratas ────────────────────────────────────────────────────────

func _setup_wheel() -> void:
	var wheel_tex := load("res://Assets/Images/roulette_table.png")
	if not wheel_tex:
		return

	_wheel_image = TextureRect.new()
	_wheel_image.texture = wheel_tex
	_wheel_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_wheel_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wheel_image.custom_minimum_size = Vector2(220, 220)
	_wheel_image.pivot_offset = Vector2(110, 110)

	# Pozicionuok viršuje dešinėje
	_wheel_image.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_wheel_image.offset_left = -260.0
	_wheel_image.offset_right = -30.0
	_wheel_image.offset_top = 80.0
	_wheel_image.offset_bottom = 310.0
	add_child(_wheel_image)

func _animate_wheel_spin() -> void:
	if not _wheel_image:
		return
	var current_rot: float = _wheel_image.rotation
	var spins := randf_range(4.0, 6.0) * TAU
	var tween := create_tween()
	tween.tween_property(_wheel_image, "rotation", current_rot + spins, 3.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	await tween.finished

# ── Skaičių lentelė ───────────────────────────────────────────────────────

func _setup_number_grid() -> void:
	_number_grid = GridContainer.new()
	_number_grid.columns = 6
	_number_grid.add_theme_constant_override("h_separation", 4)
	_number_grid.add_theme_constant_override("v_separation", 4)

	# Pozicionuok apačioje dešinėje (po ruletės ratu, netrukdo esamiems mygtukams)
	_number_grid.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_number_grid.offset_left = -370.0
	_number_grid.offset_right = -20.0
	_number_grid.offset_top = -330.0
	_number_grid.offset_bottom = -20.0
	add_child(_number_grid)

	# 0 mygtukas (žalias)
	var zero_btn := _make_number_button(0, Color(0.1, 0.55, 0.1))
	_number_grid.add_child(zero_btn)

	# 1–36
	for n in range(1, 37):
		var is_red := n in red_numbers
		var col := Color(0.7, 0.1, 0.1) if is_red else Color(0.12, 0.12, 0.12)
		var btn := _make_number_button(n, col)
		_number_grid.add_child(btn)

func _make_number_button(n: int, bg_color: Color) -> Button:
	var btn := Button.new()
	btn.text = str(n)
	btn.custom_minimum_size = Vector2(52, 38)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", style)

	var style_hover := style.duplicate() as StyleBoxFlat
	style_hover.bg_color = bg_color.lightened(0.25)
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.pressed.connect(_on_number_grid_pressed.bind(n, btn))
	return btn

func _on_number_grid_pressed(n: int, btn: Button) -> void:
	# Deselect previouus
	if _selected_number_btn:
		_selected_number_btn.modulate = Color.WHITE
	_selected_number_btn = btn
	btn.modulate = Color(1.0, 1.0, 0.3)

	if number_bet_input:
		number_bet_input.value = n
	_on_confirm_number_bet_pressed()

# ── Animuotas rezultato rodymas ────────────────────────────────────────────

func _show_winning_number_animated(num: int) -> void:
	if not winning_number_label:
		return
	var color := get_number_color(num)
	match color:
		"RED":
			winning_number_label.text = "🔴 " + str(num) + " RED"
			winning_number_label.add_theme_color_override("font_color", Color.RED)
		"BLACK":
			winning_number_label.text = "⚫ " + str(num) + " BLACK"
			winning_number_label.add_theme_color_override("font_color", Color.WHITE)
		"GREEN":
			winning_number_label.text = "🟢 0 GREEN"
			winning_number_label.add_theme_color_override("font_color", Color.LIME_GREEN)

	winning_number_label.pivot_offset = winning_number_label.size / 2.0
	winning_number_label.scale = Vector2(0.3, 0.3)
	winning_number_label.modulate.a = 0.0
	winning_number_label.visible = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(winning_number_label, "scale", Vector2(1.0, 1.0), 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(winning_number_label, "modulate:a", 1.0, 0.3)

# ── Spin logika ────────────────────────────────────────────────────────────

func _on_spin_button_pressed() -> void:
	if bet_type == "":
		show_message("Please place a bet first!")
		return
	if spin_button:
		spin_button.disabled = true
	await _animate_wheel_spin()
	spin()

func spin() -> void:
	winning_number = randi_range(0, 36)
	_show_winning_number_animated(winning_number)
	check_result()

func check_result() -> void:
	var won: bool = false
	var payout_multiplier: int = 0

	match bet_type:
		"red":
			if winning_number in red_numbers:
				won = true
				payout_multiplier = 2
		"black":
			if winning_number in black_numbers:
				won = true
				payout_multiplier = 2
		"number":
			if winning_number == chosen_number:
				won = true
				payout_multiplier = 36

	if won:
		handle_win(payout_multiplier)
	else:
		handle_loss()

func handle_loss() -> void:
	show_message("You lose. Try again!")
	if spin_button: spin_button.disabled = true
	if new_round_button: new_round_button.visible = true

func handle_win(multiplier: int) -> void:
	var winnings := current_bet * multiplier
	BalanceManager.add_balance(winnings)
	if multiplier == 36:
		show_message("🎰 JACKPOT! You win $" + str(winnings) + "! 🎰")
	else:
		show_message("Correct! You win $" + str(winnings) + "!")
	update_balance_display()
	if spin_button: spin_button.disabled = true
	if new_round_button: new_round_button.visible = true

func reset_round() -> void:
	bet_type = ""
	chosen_number = -1
	current_bet = 0
	if _selected_number_btn:
		_selected_number_btn.modulate = Color.WHITE
		_selected_number_btn = null
	if spin_button: spin_button.disabled = false
	highlight_active_bet()
	if bet_amount_spinbox:
		bet_amount_spinbox.max_value = BalanceManager.get_balance()

func _on_confirm_number_bet_pressed() -> void:
	if number_bet_input:
		chosen_number = int(number_bet_input.value)
	set_bet_type("number")

func _on_confirm_number_bet_button_pressed() -> void:
	_on_confirm_number_bet_pressed()

func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)
	if bet_amount_spinbox:
		bet_amount_spinbox.max_value = new_balance

func _on_back_button_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_bet_red_button_pressed() -> void:
	set_bet_type("red")

func _on_bet_black_button_pressed() -> void:
	set_bet_type("black")

func set_bet_type(type: String) -> void:
	if bet_amount_spinbox:
		var bet_amount := int(bet_amount_spinbox.value)
		if bet_amount > BalanceManager.get_balance():
			show_message("Insufficient balance!")
			return
		if current_bet == 0:
			BalanceManager.subtract_balance(bet_amount)
			current_bet = bet_amount
	bet_type = type
	if type != "number":
		chosen_number = -1
	highlight_active_bet()

func highlight_active_bet() -> void:
	if bet_red_button: bet_red_button.modulate = Color.WHITE
	if bet_black_button: bet_black_button.modulate = Color.WHITE
	match bet_type:
		"red":
			if bet_red_button: bet_red_button.modulate = Color(1.5, 1.5, 0.5)
		"black":
			if bet_black_button: bet_black_button.modulate = Color(1.5, 1.5, 0.5)

func get_number_color(number: int) -> String:
	if number == 0: return "GREEN"
	if number in red_numbers: return "RED"
	return "BLACK"

func show_message(message: String) -> void:
	if result_label:
		result_label.text = message
		result_label.visible = true

func _on_new_round_pressed() -> void:
	bet_type = ""
	chosen_number = -1
	current_bet = 0
	if result_label: result_label.visible = false
	if winning_number_label: winning_number_label.visible = false
	if spin_button: spin_button.disabled = false
	highlight_active_bet()
	if bet_amount_spinbox:
		bet_amount_spinbox.max_value = BalanceManager.get_balance()
	if new_round_button: new_round_button.visible = false
	if _selected_number_btn:
		_selected_number_btn.modulate = Color.WHITE
		_selected_number_btn = null
