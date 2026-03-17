extends Control

# === SCRUM-138: Card deck ===
var deck: Array = []
# === SCRUM-147: Player hand ===
var player_hand: Array = []
# === SCRUM-152: Dealer hand ===
var dealer_hand: Array = []
var dealer_card_hidden: bool = true  # SCRUM-155: Second card is hidden

# === SCRUM-113: Bet state ===
var current_bet: int = 0

@onready var balance_label: Label = $BalanceLabel
@onready var back_button: Button = $BackButton
@onready var player_score_label: Label = $PlayerScoreLabel
@onready var dealer_score_label: Label = $DealerScoreLabel  # SCRUM-172
@onready var hit_button: Button = $HitButton
@onready var stand_button: Button = $StandButton
@onready var result_label: Label = $ResultLabel
@onready var bet_spinbox: SpinBox = $BetSpinBox  # SCRUM-113
@onready var place_bet_button: Button = $PlaceBetButton  # SCRUM-113
@onready var bet_error_label: Label = $BetErrorLabel  # SCRUM-118: Klaidos žinutė

## Blackjack game scene script
func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)
	
	build_deck()
	shuffle_deck()
	
	# SCRUM-113: Initial button states - disabled until bet placed
	if hit_button:
		hit_button.disabled = true
	if stand_button:
		stand_button.disabled = true
	if result_label:
		result_label.visible = false
	
	# SCRUM-118: Set SpinBox min and max to current balance
	if bet_spinbox and BalanceManager:
		bet_spinbox.min_value = 10
		bet_spinbox.max_value = BalanceManager.get_balance()
		bet_spinbox.value = 10
		# Gauti LineEdit iš SpinBox ir prijungti signalą
		var line_edit = bet_spinbox.get_line_edit()
		if line_edit:
			line_edit.text_changed.connect(_on_bet_text_changed)
		print("DEBUG _ready: SpinBox min=", bet_spinbox.min_value, " max=", bet_spinbox.max_value)

func _on_bet_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	var value = int(new_text)
	var balance = BalanceManager.get_balance()
	if value > balance:
		show_bet_error("Per didelė suma! Max: $" + str(balance))
		if place_bet_button:
			place_bet_button.disabled = true
	elif value < 10:
		show_bet_error("Per maža suma! Min: $10")
		if place_bet_button:
			place_bet_button.disabled = true
	else:
		hide_bet_error()
		if place_bet_button:
			place_bet_button.disabled = false

func show_bet_error(message: String) -> void:
	if bet_error_label:
		bet_error_label.text = message
		bet_error_label.visible = true

func hide_bet_error() -> void:
	if bet_error_label:
		bet_error_label.visible = false

func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)
	# SCRUM-118: Update SpinBox max when balance changes
	if bet_spinbox:
		bet_spinbox.max_value = new_balance
		if bet_spinbox.value > new_balance:
			bet_spinbox.value = new_balance

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

# === SCRUM-138: Card deck ===
func build_deck() -> void:
	deck.clear()
	for _suit in range(4):
		for value in range(1, 14):
			deck.append(value)
	print("Deck built: ", deck.size(), " cards")

func shuffle_deck() -> void:
	deck.shuffle()
	print("Deck shuffled. First 5 cards: ", deck.slice(0, 5))

func deal_card() -> int:
	if deck.is_empty():
		print("Deck empty! Rebuilding...")
		build_deck()
		shuffle_deck()
	return deck.pop_back()

# === SCRUM-157: Score calculation ===
func calculate_score(hand: Array) -> int:
	var score: int = 0
	var aces: int = 0
	for card in hand:
		if card == 1:  # Ace
			aces += 1
			score += 11
		elif card >= 11:  # Face cards (Jack, Queen, King)
			score += 10
		else:  # Number cards 2-10
			score += card
	# Reduce Ace value from 11 to 1 if busting
	while score > 21 and aces > 0:
		score -= 10
		aces -= 1
	return score

func update_player_score() -> void:
	var score = calculate_score(player_hand)
	if player_score_label:
		player_score_label.text = "Your Score: " + str(score)

func update_dealer_score() -> void:
	if dealer_score_label:
		if dealer_card_hidden:
			var first_card = dealer_hand[0]
			var visible_score: int
			if first_card == 1:
				visible_score = 11
			elif first_card >= 11:
				visible_score = 10
			else:
				visible_score = first_card
			dealer_score_label.text = "Dealer: " + str(visible_score) + " + ?"
		else:
			dealer_score_label.text = "Dealer: " + str(calculate_score(dealer_hand))

func deal_initial_player_cards() -> void:
	player_hand.clear()
	player_hand.append(deal_card())
	player_hand.append(deal_card())
	print("Player hand: ", player_hand)
	update_player_score()

func deal_initial_dealer_cards() -> void:
	dealer_hand.clear()
	dealer_hand.append(deal_card())
	dealer_hand.append(deal_card())
	dealer_card_hidden = true
	update_dealer_score()
	print("Dealer hand: ", dealer_hand, " (second card hidden)")

func start_round() -> void:
	if result_label:
		result_label.visible = false
	shuffle_deck()
	deal_initial_player_cards()
	deal_initial_dealer_cards()
	print("=== NEW ROUND STARTED ===")

# === SCRUM-113: Bet input ===
func get_bet_amount() -> int:
	if bet_spinbox:
		return int(bet_spinbox.value)
	return 0

# === SCRUM-118: Bet validation ===
func validate_bet(amount: int) -> bool:
	var balance = BalanceManager.get_balance()
	print("DEBUG validate_bet: amount=", amount, " balance=", balance)
	
	# Check for minimum bet
	if amount < 10:
		print("DEBUG: Bet too small!")
		show_result("Minimum bet is $10!")
		if bet_spinbox:
			bet_spinbox.value = 10
		return false
	
	# Check if player can afford bet
	if amount > balance:
		print("DEBUG: Bet too big!")
		show_result("Insufficient balance! Max: $" + str(balance))
		if bet_spinbox:
			bet_spinbox.max_value = balance
			bet_spinbox.value = balance
		return false
	
	print("DEBUG: Validation passed!")
	return true

func place_bet() -> void:
	var amount = get_bet_amount()
	
	if not validate_bet(amount):
		return
	
	current_bet = amount
	
	# SCRUM-123: Deduct bet from balance
	BalanceManager.subtract_balance(current_bet)
	print("Bet placed: $", current_bet, " | New balance: $", BalanceManager.get_balance())
	
	# Disable betting UI during round
	if bet_spinbox:
		bet_spinbox.editable = false
	if place_bet_button:
		place_bet_button.disabled = true
	
	# Enable game buttons
	if hit_button:
		hit_button.disabled = false
	if stand_button:
		stand_button.disabled = false
	
	# Start the round
	start_round()

func _on_place_bet_button_pressed() -> void:
	print("DEBUG: Place Bet button pressed!")
	place_bet()

# === SCRUM-162: Hit button ===
func hit() -> void:
	player_hand.append(deal_card())
	update_player_score()
	print("Player HITS. Hand: ", player_hand, " Score: ", calculate_score(player_hand))
	if calculate_score(player_hand) > 21:
		show_result("BUST! You lose.")
		end_round(false)

func show_result(message: String) -> void:
	print("DEBUG show_result: ", message)
	if result_label:
		result_label.text = message
		result_label.visible = true
	else:
		print("ERROR: result_label is null!")

func end_round(player_wins: bool) -> void:
	if hit_button:
		hit_button.disabled = true
	if stand_button:
		stand_button.disabled = true
	
	# After 2 seconds, reset display (optional)
	await get_tree().create_timer(2.0).timeout
	reset_for_new_round()
	
	# SCRUM-123: Handle payouts
	if player_wins:
		# Player wins: return bet + winnings (2x bet total)
		var winnings = current_bet * 2
		BalanceManager.add_balance(winnings)
		print("Player wins! Payout: $", winnings)
	elif result_label and "PUSH" in result_label.text.to_upper():
		# Push (tie): return original bet
		BalanceManager.add_balance(current_bet)
		print("Push! Bet returned: $", current_bet)
	else:
		# Player loses: bet already deducted, nothing to do
		print("Player loses. Bet lost: $", current_bet)
	
	# Re-enable betting for next round
	if bet_spinbox:
		bet_spinbox.editable = true
	if place_bet_button:
		place_bet_button.disabled = false
	
	# Reset current bet
	current_bet = 0

func reset_for_new_round() -> void:
	if result_label:
		result_label.visible = false
	player_hand.clear()
	dealer_hand.clear()
	dealer_card_hidden = true
	if player_score_label:
		player_score_label.text = "Your Score: 0"
	if dealer_score_label:
		dealer_score_label.text = "Dealer: ?"

func _on_hit_button_pressed() -> void:
	hit()

# === SCRUM-167: Stand button ===
func stand() -> void:
	print("Player STANDS with score: ", calculate_score(player_hand))
	if hit_button:
		hit_button.disabled = true
	if stand_button:
		stand_button.disabled = true
	dealer_draw()

func _on_stand_button_pressed() -> void:
	stand()

# === SCRUM-172: Dealer draw logic ===
func reveal_dealer_card() -> void:
	dealer_card_hidden = false
	update_dealer_score()
	print("Dealer reveals hidden card! Full hand: ", dealer_hand)

func dealer_draw() -> void:
	reveal_dealer_card()
	
	while calculate_score(dealer_hand) < 17:
		dealer_hand.append(deal_card())
		update_dealer_score()
		print("Dealer draws. Hand: ", dealer_hand, " Score: ", calculate_score(dealer_hand))
	
	print("Dealer stands with: ", calculate_score(dealer_hand))
	check_winner()

func check_winner() -> void:
	var player_score = calculate_score(player_hand)
	var dealer_score = calculate_score(dealer_hand)
	
	print("=== FINAL SCORES ===")
	print("Player: ", player_score)
	print("Dealer: ", dealer_score)
	
	if dealer_score > 21:
		show_result("Dealer BUSTS! You WIN!")
		end_round(true)
	elif player_score > dealer_score:
		show_result("You WIN!")
		end_round(true)
	elif dealer_score > player_score:
		show_result("Dealer WINS!")
		end_round(false)
	else:
		show_result("PUSH! It's a tie.")
		end_round(false)
