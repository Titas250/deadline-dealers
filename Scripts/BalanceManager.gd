extends Node
var balance: int = 1000
signal balance_changed(new_balance: int)

func get_balance() -> int:
	return balance

func set_balance(value: int) -> void:
	balance = max(0, value)
	balance_changed.emit(balance)

func add_balance(amount: int) -> void:
	balance += amount
	balance_changed.emit(balance)

# SCRUM-129: add_funds alias for sprint compatibility
func add_funds(amount: int) -> void:
	add_balance(amount)

func subtract_balance(amount: int) -> bool:
	if amount > balance:
		return false
	balance -= amount
	balance_changed.emit(balance)
	return true

func can_afford(amount: int) -> bool:
	return balance >= amount

func reset_balance() -> void:
	balance = 1000
	balance_changed.emit(balance)
