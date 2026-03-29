extends Control

@onready var balance_label: Label = $BalanceLabel
@onready var back_button: Button = $BackButton

# === SCRUM-198: Game state ===
var winning_number: int = -1  # -1 = no spin yet

func _ready() -> void:
	update_balance_display()
	if BalanceManager:
		BalanceManager.balance_changed.connect(_on_balance_changed)

func update_balance_display() -> void:
	if balance_label and BalanceManager:
		balance_label.text = "Balance: $" + str(BalanceManager.get_balance())

func _on_balance_changed(new_balance: int) -> void:
	if balance_label:
		balance_label.text = "Balance: $" + str(new_balance)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

# === SCRUM-198: Spin logic ===
func spin() -> void:
	winning_number = randi_range(0, 36)
	print("=== SPIN RESULT ===")
	print("Winning number: ", winning_number)
	print("Color: ", get_number_color(winning_number))

func get_number_color(number: int) -> String:
	if number == 0:
		return "GREEN"
	var red_numbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
	if number in red_numbers:
		return "RED"
	return "BLACK"
