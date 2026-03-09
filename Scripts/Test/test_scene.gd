extends Node

func _ready() -> void:
	print("=== SCRUM-104 TESTAS ===")
	
	# SCRUM-105: Test get_balance()
	var initial = BalanceManager.get_balance()
	print("1. Pradinis balansas: ", initial)
	assert(initial == 1000, "KLAIDA: Pradinis balansas turėtų būti 1000!")
	print("   ✅ get_balance() veikia")
	
	# Pakeisti balansą
	BalanceManager.balance = 500
	print("2. Po pakeitimo į 500: ", BalanceManager.get_balance())
	assert(BalanceManager.get_balance() == 500, "KLAIDA: Balansas turėtų būti 500!")
	print("   ✅ Balansas pakeistas")
	
	# SCRUM-106, SCRUM-107: Test reset_balance()
	BalanceManager.reset_balance()
	var after_reset = BalanceManager.get_balance()
	print("3. Po reset_balance(): ", after_reset)
	assert(after_reset == 1000, "KLAIDA: Po reset turėtų būti 1000!")
	print("   ✅ reset_balance() veikia")
	
	print("=== VISI TESTAI PRAEITI ✅ ===")
