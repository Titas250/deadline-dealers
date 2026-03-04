extends Control

## MainMenu script
## SCRUM-93: Make menu buttons change scene
## SCRUM-94: Create Scripts/MainMenu.gd and attach it to the MainMenu root node


## SCRUM-96: Connect 'Play Blackjack' pressed signal
func _on_game_one_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Blackjack/Blackjack.tscn")


## SCRUM-97: Connect 'Play Roulette' pressed signal
func _on_game_two_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Roulette/Roulette.tscn")


func _on_settings_pressed() -> void:
	# Settings scene placeholder - can be implemented later
	pass
