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

## Blackjack game scene script
## SCRUM-133: Create Blackjack scene
## SCRUM-108: Show balance on screen

func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)
	
	# SCRUM-141: Build deck on ready
	build_deck()
	shuffle_deck()
	

# === SCRUM-147: Deal cards ===
## SCRUM-148: Deal one card from deck (pop last element)
func deal_card() -> int:
	# If deck is empty, rebuild and shuffle
	if deck.is_empty():
		print("Deck empty! Rebuilding...")
		build_deck()
		shuffle_deck()
	return deck.pop_back()

## SCRUM-150: Deal 2 initial cards to player
func deal_initial_player_cards() -> void:
	player_hand.clear()  # Clear any existing cards
	player_hand.append(deal_card())
	player_hand.append(deal_card())
	# SCRUM-151: Print verification
	print("Player hand: ", player_hand)

## SCRUM-154: Deal 2 initial cards to dealer
func deal_initial_dealer_cards() -> void:
	dealer_hand.clear()
	dealer_hand.append(deal_card())
	dealer_hand.append(deal_card())  # SCRUM-155: This card stays hidden
	dealer_card_hidden = true
# SCRUM-156: Print verification
	print("Dealer hand: ", dealer_hand, " (second card hidden)")

## Start a new round of Blackjack
## Combines all dealing functions
func start_round() -> void:
	# SCRUM-146: Shuffle at each round start
	shuffle_deck()
	
	# Deal cards to both players
	deal_initial_player_cards()
	deal_initial_dealer_cards()
	
	print("=== NEW ROUND STARTED ===")

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
	# Loop 4 times for 4 suits (we ignore suits, just need 52 cards)
	for _suit in range(4):
		# Values 1-13: Ace=1, 2-10, Jack=11, Queen=12, King=13
		for value in range(1, 14):
			deck.append(value)
	# SCRUM-142: Print confirmation
	print("Deck built: ", deck.size(), " cards")
	print("Deck contents: ", deck)
func shuffle_deck() -> void:
	deck.shuffle()
	print("Deck shuffled. First 5 cards: ", deck.slice(0, 5))
	
