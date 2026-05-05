extends CanvasLayer

# SCRUM-290: Fade in/out scene transitions
# Užregistruok kaip Autoload: Project > Project Settings > Autoload
# Node name: "SceneTransition", path: res://Scripts/Autoload/SceneTransition.gd

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a = 0.0
	add_child(_overlay)
	_fade_in()

func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_OUT)

func change_scene(path: String) -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.35).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().change_scene_to_file(path)
	var tween2 = create_tween()
	tween2.tween_property(_overlay, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_OUT)
