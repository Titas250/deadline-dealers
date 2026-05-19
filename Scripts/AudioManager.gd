extends Node

const AUDIO_PATHS := {
	"card_deal":      "res://Assets/Audio/card_deal.ogg",
	"bj_win":         "res://Assets/Audio/blackjack_win.ogg",
	"bj_lose":        "res://Assets/Audio/blackjack_lose.ogg",
	"roulette_spin":  "res://Assets/Audio/roulette_spin.ogg",
	"roulette_win":   "res://Assets/Audio/roulette_win.ogg",
	"roulette_lose":  "res://Assets/Audio/roulette_lose.ogg",
}

var _sfx_player: AudioStreamPlayer
var _streams: Dictionary = {}

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "Master"
	add_child(_sfx_player)

	for key in AUDIO_PATHS:
		var path: String = AUDIO_PATHS[key]
		if ResourceLoader.exists(path):
			var s = load(path)
			if s != null:
				_streams[key] = s

func play_sfx(key: String, volume_db: float = 0.0) -> void:
	if not _streams.has(key):
		return
	_sfx_player.stream = _streams[key]
	_sfx_player.volume_db = volume_db
	_sfx_player.play()
