extends Node

var games_played: int = 0
var wins: int = 0
var losses: int = 0
var biggest_win: int = 0

func record_result(won: bool, amount: int = 0) -> void:
	games_played += 1
	if won:
		wins += 1
		if amount > biggest_win:
			biggest_win = amount
	else:
		losses += 1

func get_win_rate() -> float:
	if games_played == 0:
		return 0.0
	return float(wins) / float(games_played) * 100.0

func reset() -> void:
	games_played = 0
	wins = 0
	losses = 0
	biggest_win = 0
