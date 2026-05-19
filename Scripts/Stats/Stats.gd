extends Control

@onready var games_label: Label = $StatsContainer/GamesPlayedLabel
@onready var wins_label: Label = $StatsContainer/WinsLabel
@onready var losses_label: Label = $StatsContainer/LossesLabel
@onready var biggest_win_label: Label = $StatsContainer/BiggestWinLabel
@onready var win_rate_label: Label = $StatsContainer/WinRateLabel

func _ready() -> void:
	_update_labels()

func _update_labels() -> void:
	games_label.text = "Žaidimai: " + str(StatsManager.games_played)
	wins_label.text = "Laimėjimai: " + str(StatsManager.wins)
	losses_label.text = "Pralaimėjimai: " + str(StatsManager.losses)
	biggest_win_label.text = "Didžiausias laimėjimas: $" + str(StatsManager.biggest_win)
	win_rate_label.text = "Laimėjimų rodiklis: " + "%.1f" % StatsManager.get_win_rate() + "%"

func _on_back_button_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_reset_pressed() -> void:
	StatsManager.reset()
	_update_labels()
