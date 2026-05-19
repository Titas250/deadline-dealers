extends Control

func _ready() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.2)
	tween.tween_interval(1.8)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	SceneTransition.change_scene("res://Scenes/MainMenu/MainMenu.tscn")
