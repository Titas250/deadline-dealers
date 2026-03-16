extends Control

# === SCRUM-138: Card deck ===
var deck: Array = []
var player_hand: Array = []

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
## SCRUM-140: Build deck with 52 cards (4 suits × 13 values)
func build_deck() -> void:
	deck.clear()
	for _suit in range(4):
		for value in range(1, 14):
			deck.append(value)
	print("Deck built: ", deck.size(), " cards")
	print("Deck contents: ", deck)

# === SCRUM-162: Hit button ===

func deal_card() -> int:
	if deck.is_empty():
		build_deck()
	var idx = randi() % deck.size()
	var card = deck[idx]
	deck.remove_at(idx)
	return card

func calculate_score(hand: Array) -> int:
	var score = 0
	for card in hand:
		score += min(card, 10)
	return score

func update_player_score() -> void:
	if player_score_label:
		player_score_label.text = "Your Score: " + str(calculate_score(player_hand))

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

## Connected to StandButton.pressed signal (SCRUM-167)
func _on_stand_button_pressed() -> void:
	pass