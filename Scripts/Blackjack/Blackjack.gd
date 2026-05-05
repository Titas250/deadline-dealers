extends Control

# SCRUM-279: Kortų dalinimo slide-in animacija
# SCRUM-280: Dilerio kortos flip animacija
# SCRUM-282: Laimėjimo/pralaimėjimo animuotas overlay
# Reikalauja: Scripts/Blackjack/Card.gd (Titas)

const CardScript = preload("res://Scripts/Blackjack/Card.gd")

var deck: Array = []
var player_hand: Array = []
var dealer_hand: Array = []
var dealer_card_hidden: bool = true
var current_bet: int = 0

# Vizualiniai kortų konteineriai
var _dealer_container: HBoxContainer
var _player_container: HBoxContainer
var _dealer_cards: Array = []
var _player_cards: Array = []

# Win/loss overlay
var _result_overlay: PanelContainer
var _overlay_label: Label

@onready var balance_label: Label = $BalanceLabel
@onready var back_button: Button = $BackButton
@onready var player_score_label: Label = $PlayerScoreLabel
@onready var dealer_score_label: Label = $DealerScoreLabel
@onready var hit_button: Button = $HitButton
@onready var stand_button: Button = $StandButton
@onready var result_label: Label = $ResultLabel
@onready var bet_spinbox: SpinBox = $BetSpinBox
@onready var place_bet_button: Button = $PlaceBetButton
@onready var bet_error_label: Label = $BetErrorLabel
@onready var play_again_button: Button = $PlayAgainButton

func _ready() -> void:
	_setup_card_containers()
	_setup_result_overlay()
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)
	build_deck()
	shuffle_deck()

	if hit_button:
		hit_button.icon = load("res://Assets/Images/hit.png")
		hit_button.expand_icon = true
		hit_button.text = ""
		hit_button.disabled = true
	if stand_button:
		stand_button.icon = load("res://Assets/Images/stand.png")
		stand_button.expand_icon = true
		stand_button.text = ""
		stand_button.disabled = true
	if result_label:
		result_label.visible = false
	if bet_spinbox and BalanceManager:
		bet_spinbox.min_value = 10
		bet_spinbox.max_value = BalanceManager.get_balance()
		bet_spinbox.value = 10
		var line_edit = bet_spinbox.get_line_edit()
		if line_edit:
			line_edit.text_changed.connect(_on_bet_text_changed)
	if play_again_button:
		play_again_button.visible = false
		if not play_again_button.pressed.is_connected(_on_play_again_pressed):
			play_again_button.pressed.connect(_on_play_again_pressed)

# ── Kortų konteinerių kūrimas ──────────────────────────────────────────────

func _setup_card_containers() -> void:
	_dealer_container = HBoxContainer.new()
	_dealer_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_dealer_container.add_theme_constant_override("separation", 10)
	_dealer_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_dealer_container.offset_top = 165.0
	_dealer_container.offset_bottom = 285.0
	_dealer_container.offset_left = -250.0
	_dealer_container.offset_right = 250.0
	add_child(_dealer_container)

	_player_container = HBoxContainer.new()
	_player_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_player_container.add_theme_constant_override("separation", 10)
	_player_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_player_container.offset_top = 295.0
	_player_container.offset_bottom = 415.0
	_player_container.offset_left = -250.0
	_player_container.offset_right = 250.0
	add_child(_player_container)

func _setup_result_overlay() -> void:
	_result_overlay = PanelContainer.new()
	_result_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_result_overlay.offset_left = -180.0
	_result_overlay.offset_right = 180.0
	_result_overlay.offset_top = -50.0
	_result_overlay.offset_bottom = 50.0
	_result_overlay.visible = false
	_result_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.75)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	_result_overlay.add_theme_stylebox_override("panel", style)

	_overlay_label = Label.new()
	_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_overlay_label.add_theme_font_size_override("font_size", 42)
	_result_overlay.add_child(_overlay_label)
	add_child(_result_overlay)

# ── Kortų vizualai ─────────────────────────────────────────────────────────

func _spawn_card(value: int, hidden: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	card.set_script(CardScript)
	return card

func _deal_card_to(container: HBoxContainer, cards_arr: Array, value: int, hidden: bool = false) -> void:
	var card := _spawn_card(value, hidden)
	card.modulate.a = 0.0
	card.position = Vector2(-80, 0)
	container.add_child(card)
	card.setup(value, randi() % 4, hidden)
	cards_arr.append(card)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(card, "modulate:a", 1.0, 0.25)
	tween.tween_property(card, "position:x", 0.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _clear_card_containers() -> void:
	for c in _dealer_cards:
		if is_instance_valid(c):
			c.queue_free()
	for c in _player_cards:
		if is_instance_valid(c):
			c.queue_free()
	_dealer_cards.clear()
	_player_cards.clear()

# ── Result overlay ─────────────────────────────────────────────────────────

func _show_result_animated(message: String, win: bool) -> void:
	if result_label:
		result_label.text = message
		result_label.visible = true

	if not _result_overlay or not _overlay_label:
		return

	_overlay_label.text = message
	var col := Color(0.2, 0.9, 0.3) if win else Color(0.9, 0.2, 0.2)
	_overlay_label.add_theme_color_override("font_color", col)

	_result_overlay.modulate.a = 0.0
	_result_overlay.scale = Vector2(0.6, 0.6)
	_result_overlay.pivot_offset = _result_overlay.size / 2.0
	_result_overlay.visible = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_result_overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(_result_overlay, "scale", Vector2(1.0, 1.0), 0.35)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_result_overlay() -> void:
	if _result_overlay:
		_result_overlay.visible = false
	if result_label:
		result_label.visible = false

# ── Flip animacija dilerio kortai ──────────────────────────────────────────

func _flip_dealer_hidden_card() -> void:
	if _dealer_cards.is_empty():
		return
	var hidden_card: PanelContainer = _dealer_cards[1] if _dealer_cards.size() > 1 else _dealer_cards[0]
	var center_x := hidden_card.size.x / 2.0
	hidden_card.pivot_offset = Vector2(center_x, hidden_card.size.y / 2.0)

	var tween1 := create_tween()
	tween1.tween_property(hidden_card, "scale:x", 0.0, 0.15).set_ease(Tween.EASE_IN)
	await tween1.finished

	if hidden_card and is_instance_valid(hidden_card):
		hidden_card.call("reveal")

	var tween2 := create_tween()
	tween2.tween_property(hidden_card, "scale:x", 1.0, 0.15).set_ease(Tween.EASE_OUT)
	await tween2.finished

# ── Žaidimo logika (originali + animacijos) ────────────────────────────────

func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)
	if bet_spinbox:
		bet_spinbox.max_value = new_balance
		if bet_spinbox.value > new_balance:
			bet_spinbox.value = new_balance

func _on_back_button_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func build_deck() -> void:
	deck.clear()
	for _suit in range(4):
		for value in range(1, 14):
			deck.append(value)

func shuffle_deck() -> void:
	deck.shuffle()

func deal_card() -> int:
	if deck.is_empty():
		build_deck()
		shuffle_deck()
	return deck.pop_back()

func calculate_score(hand: Array) -> int:
	var score: int = 0
	var aces: int = 0
	for card in hand:
		if card == 1:
			aces += 1
			score += 11
		elif card >= 11:
			score += 10
		else:
			score += card
	while score > 21 and aces > 0:
		score -= 10
		aces -= 1
	return score

func update_player_score() -> void:
	var score := calculate_score(player_hand)
	if player_score_label:
		player_score_label.text = "Your Score: " + str(score)

func update_dealer_score() -> void:
	if not dealer_score_label:
		return
	if dealer_card_hidden:
		var first_card: int = dealer_hand[0]
		var visible_score: int
		if first_card == 1: visible_score = 11
		elif first_card >= 11: visible_score = 10
		else: visible_score = first_card
		dealer_score_label.text = "Dealer: " + str(visible_score) + " + ?"
	else:
		dealer_score_label.text = "Dealer: " + str(calculate_score(dealer_hand))

func deal_initial_player_cards() -> void:
	player_hand.clear()
	var c1 := deal_card()
	var c2 := deal_card()
	player_hand.append(c1)
	player_hand.append(c2)
	_deal_card_to(_player_container, _player_cards, c1)
	await get_tree().create_timer(0.2).timeout
	_deal_card_to(_player_container, _player_cards, c2)
	update_player_score()

func deal_initial_dealer_cards() -> void:
	dealer_hand.clear()
	var c1 := deal_card()
	var c2 := deal_card()
	dealer_hand.append(c1)
	dealer_hand.append(c2)
	dealer_card_hidden = true
	_deal_card_to(_dealer_container, _dealer_cards, c1, false)
	await get_tree().create_timer(0.2).timeout
	_deal_card_to(_dealer_container, _dealer_cards, c2, true)
	update_dealer_score()

func start_round() -> void:
	_hide_result_overlay()
	shuffle_deck()
	_clear_card_containers()
	await deal_initial_dealer_cards()
	await deal_initial_player_cards()

func get_bet_amount() -> int:
	if bet_spinbox:
		return int(bet_spinbox.value)
	return 0

func validate_bet(amount: int) -> bool:
	var balance := BalanceManager.get_balance()
	if amount < 10:
		show_result("Minimum bet is $10!")
		if bet_spinbox: bet_spinbox.value = 10
		return false
	if amount > balance:
		show_result("Insufficient balance! Max: $" + str(balance))
		if bet_spinbox:
			bet_spinbox.max_value = balance
			bet_spinbox.value = balance
		return false
	return true

func place_bet() -> void:
	var amount := get_bet_amount()
	if not validate_bet(amount):
		return
	current_bet = amount
	BalanceManager.subtract_balance(current_bet)
	if bet_spinbox: bet_spinbox.editable = false
	if place_bet_button: place_bet_button.disabled = true
	if hit_button: hit_button.disabled = false
	if stand_button: stand_button.disabled = false
	await start_round()

func _on_place_bet_button_pressed() -> void:
	place_bet()

func _on_bet_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	var value := int(new_text)
	var balance := BalanceManager.get_balance()
	if value > balance:
		show_bet_error("Per didelė suma! Max: $" + str(balance))
		if place_bet_button: place_bet_button.disabled = true
	elif value < 10:
		show_bet_error("Per maža suma! Min: $10")
		if place_bet_button: place_bet_button.disabled = true
	else:
		hide_bet_error()
		if place_bet_button: place_bet_button.disabled = false

func show_bet_error(message: String) -> void:
	if bet_error_label:
		bet_error_label.text = message
		bet_error_label.visible = true

func hide_bet_error() -> void:
	if bet_error_label:
		bet_error_label.visible = false

func hit() -> void:
	var card := deal_card()
	player_hand.append(card)
	_deal_card_to(_player_container, _player_cards, card)
	update_player_score()
	if calculate_score(player_hand) > 21:
		end_round(false)

func show_result(message: String) -> void:
	if result_label:
		result_label.text = message
		result_label.visible = true

func end_round(player_wins: bool) -> void:
	if hit_button: hit_button.disabled = true
	if stand_button: stand_button.disabled = true

	if player_wins:
		var winnings := current_bet * 2
		BalanceManager.add_funds(winnings)
		_show_result_animated("You Win! +$" + str(winnings), true)
	elif result_label and "PUSH" in result_label.text.to_upper():
		BalanceManager.add_funds(current_bet)
		_show_result_animated("Push! Bet returned", false)
	else:
		_show_result_animated("You Lose!", false)

	update_balance_display()
	if has_node("PlayAgainButton"):
		$PlayAgainButton.visible = true

func reset_for_new_round() -> void:
	_hide_result_overlay()
	_clear_card_containers()
	player_hand.clear()
	dealer_hand.clear()
	dealer_card_hidden = true
	if player_score_label: player_score_label.text = "Your Score: 0"
	if dealer_score_label: dealer_score_label.text = "Dealer: ?"

func _on_hit_button_pressed() -> void:
	hit()

func stand() -> void:
	if hit_button: hit_button.disabled = true
	if stand_button: stand_button.disabled = true
	dealer_draw()

func _on_stand_button_pressed() -> void:
	stand()

func reveal_dealer_card() -> void:
	dealer_card_hidden = false
	await _flip_dealer_hidden_card()
	update_dealer_score()

func dealer_draw() -> void:
	await reveal_dealer_card()
	while calculate_score(dealer_hand) < 17:
		var card := deal_card()
		dealer_hand.append(card)
		_deal_card_to(_dealer_container, _dealer_cards, card)
		await get_tree().create_timer(0.3).timeout
		update_dealer_score()
	check_winner()

func check_winner() -> void:
	var player_score := calculate_score(player_hand)
	var dealer_score := calculate_score(dealer_hand)
	if dealer_score > 21:
		end_round(true)
	elif player_score > dealer_score:
		end_round(true)
	elif dealer_score > player_score:
		end_round(false)
	else:
		show_result("PUSH! It's a tie.")
		end_round(false)

func _on_play_again_pressed() -> void:
	reset_for_new_round()
	current_bet = 0
	if bet_spinbox:
		bet_spinbox.editable = true
		bet_spinbox.max_value = BalanceManager.get_balance()
	if place_bet_button:
		place_bet_button.disabled = false
	if play_again_button:
		play_again_button.visible = false
