extends Control

# === SCRUM-138: Card deck ===
var deck: Array = []
# === SCRUM-147: Player hand ===
var player_hand: Array = []
# === SCRUM-152: Dealer hand ===
var dealer_hand: Array = []
var dealer_card_hidden: bool = true  # SCRUM-155: Second card is hidden

@onready var balance_label: Label = $BalanceLabel
@onready var back_button: Button = $BackButton
@onready var player_score_label: Label = $PlayerScoreLabel
@onready var hit_button: Button = $HitButton
@onready var stand_button: Button = $StandButton
@onready var result_label: Label = $ResultLabel

## Blackjack game scene script
## SCRUM-133: Create Blackjack scene
## SCRUM-108: Show balance on screen
func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)
	# SCRUM-141: Build deck on ready
	build_deck()
	start_round()

## SCRUM-111: Set BalanceLabel.text = 'Balance: ' + str(BalanceManager.get_balance())
## SCRUM-112: Create update_balance_display() helper
func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)

## SCRUM-135: Back to Menu button
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

# === SCRUM-138: Card deck ===
## SCRUM-139: deck array declared above
## SCRUM-140: Build deck with 52 cards (4 suits x 13 values)
func build_deck() -> void:
	deck.clear()
	for _suit in range(4):
		for value in range(1, 14):
			deck.append(value)
	print("Deck built: ", deck.size(), " cards")

# === SCRUM-147: Shuffle deck ===
func shuffle_deck() -> void:
	deck.shuffle()
	print("Deck shuffled. First 5 cards: ", deck.slice(0, 5))

# === SCRUM-148: Deal one card ===
func deal_card() -> int:
	if deck.is_empty():
		print("Deck empty! Rebuilding...")
		build_deck()
		shuffle_deck()
	return deck.pop_back()

# === SCRUM-157: Score calculation ===
## SCRUM-158: Calculate hand score with proper Blackjack rules
## - Cards 2-10 = face value
## - Face cards (J=11, Q=12, K=13) = 10 points
## - Ace (1) = 11 points, reduces to 1 if busting
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

## SCRUM-160: Update player score label on screen
func update_player_score() -> void:
	var score = calculate_score(player_hand)
	if player_score_label:
		player_score_label.text = "Your Score: " + str(score)

## SCRUM-150: Deal 2 initial cards to player
func deal_initial_player_cards() -> void:
	player_hand.clear()
	player_hand.append(deal_card())
	player_hand.append(deal_card())
	print("Player hand: ", player_hand)
	update_player_score()  # SCRUM-161: Update score after dealing

## SCRUM-154: Deal 2 initial cards to dealer
func deal_initial_dealer_cards() -> void:
	dealer_hand.clear()
	dealer_hand.append(deal_card())
	dealer_hand.append(deal_card())  # SCRUM-155: This card stays hidden
	dealer_card_hidden = true
	# SCRUM-156: Print verification
	print("Dealer hand: ", dealer_hand, " (second card hidden)")

## Start a new round of Blackjack
func start_round() -> void:
	# SCRUM-146: Shuffle at each round start
	shuffle_deck()
	deal_initial_player_cards()
	deal_initial_dealer_cards()
	print("=== NEW ROUND STARTED ===")

# === SCRUM-162: Hit button ===
## SCRUM-165: Deal one card to player and check for bust
func hit() -> void:
	player_hand.append(deal_card())
	update_player_score()
	print("Player HITS. Hand: ", player_hand, " Score: ", calculate_score(player_hand))
	# SCRUM-166: Check for bust (over 21)
	if calculate_score(player_hand) > 21:
		show_result("BUST! You lose.")
		end_round(false)

## Show result message on screen
func show_result(message: String) -> void:
	if result_label:
		result_label.text = message
		result_label.visible = true

## End round - disable action buttons
func end_round(player_wins: bool) -> void:
	if hit_button:
		hit_button.disabled = true
	if stand_button:
		stand_button.disabled = true

## SCRUM-164: Connected to HitButton.pressed signal
func _on_hit_button_pressed() -> void:
	hit()

# === SCRUM-167: Stand button ===
## SCRUM-170: Disable buttons and trigger dealer
func stand() -> void:
	print("Player STANDS with score: ", calculate_score(player_hand))
	# Disable player action buttons
	if hit_button:
		hit_button.disabled = true
	if stand_button:
		stand_button.disabled = true
	# SCRUM-171: Trigger dealer's turn
	dealer_draw()

## Placeholder - will be implemented in SCRUM-172
func dealer_draw() -> void:
	print("TODO: Dealer draw logic")
	pass

## SCRUM-169: Connected to StandButton.pressed signal
func _on_stand_button_pressed() -> void:
	stand()
