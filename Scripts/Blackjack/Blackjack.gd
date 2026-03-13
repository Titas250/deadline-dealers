extends Control

# === SCRUM-138: Card deck ===
var deck: Array = []

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
	
