extends Control

func _ready() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)

func _on_retry_pressed() -> void:
	BalanceManager.reset_balance()
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_menu_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")
