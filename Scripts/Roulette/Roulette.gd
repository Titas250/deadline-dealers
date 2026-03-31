

extends Control

@onready var balance_label: Label = $BalanceLabel
@onready var spin_button: Button = $SpinButton           # SCRUM-219
@onready var result_label: Label = $ResultLabel
@onready var back_button: Button = $BackButton
@onready var bet_red_button: Button = $BetRedButton
@onready var bet_black_button: Button = $BetBlackButton
@onready var number_bet_input: SpinBox = $NumberBetInput       # SCRUM-214
@onready var confirm_number_button: Button = $ConfirmNumberBetButton  # SCRUM-216

# === SCRUM-198: Game state ===
var winning_number: int = -1
var bet_type: String = ""
var chosen_number: int = -1
var current_bet: int = 0
var red_numbers: Array = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]


func _on_confirm_number_bet_pressed() -> void:
	if number_bet_input:
		chosen_number = int(number_bet_input.value)
		# SCRUM-217: Number bet clears red/black bet
		set_bet_type("number")
		print("Number bet confirmed: ", chosen_number)

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
	if number in red_numbers:
		return "RED"
	return "BLACK"

# === SCRUM-203: Bet Red ===
func _on_bet_red_button_pressed() -> void: 
	set_bet_type("red")

# === SCRUM-208: Bet Black ===
func _on_bet_black_button_pressed() -> void:
	set_bet_type("black")

func set_bet_type(type: String) -> void:
	bet_type = type
	chosen_number = -1
	highlight_active_bet()
	print("Bet type set to: ", bet_type)

func highlight_active_bet() -> void:
	# Reset all bet buttons to normal
	if bet_red_button:
		bet_red_button.modulate = Color.WHITE
	if bet_black_button:
		bet_black_button.modulate = Color.WHITE
	if confirm_number_button:
		confirm_number_button.modulate = Color.WHITE
	
	# Highlight active
	match bet_type:
		"red":
			if bet_red_button:
				bet_red_button.modulate = Color(1.5, 1.5, 0.5)
		"black":
			if bet_black_button:
				bet_black_button.modulate = Color(1.5, 1.5, 0.5)
		"number":
			if confirm_number_button:
				confirm_number_button.modulate = Color(1.5, 1.5, 0.5)


func _on_confirm_number_bet_button_pressed() -> void:
	pass # Replace with function body.



func _on_spin_button_pressed() -> void:
	if bet_type == "":
		show_message("Please place a bet first!")
		return
	if spin_button:
		spin_button.disabled = true
		spin()
		
func show_message(message: String) -> void:
	if result_label:
		result_label.text = message
		result_label.visible = true
