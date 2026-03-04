extends Control

## Roulette game scene script
## SCRUM-193: Create Roulette scene
## SCRUM-108: Show balance on screen

@onready var balance_label: Label = $BalanceLabel
@onready var back_button: Button = $BackButton


func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)


## SCRUM-111: Set BalanceLabel.text = 'Balance: ' + str(BalanceManager.get_balance())
## SCRUM-112: Create update_balance_display() helper
func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())


func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)


## SCRUM-195: Back to Menu button
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
