extends Button

# SCRUM-287: Hover ir press animacijos visiems mygtukams
# Naudojimas: pakeisk mygtuko script į šį failą arba
# iššauk setup_animated_button(button) iš bet kurios scenos

func _ready() -> void:
	pivot_offset = size / 2.0
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	button_down.connect(_on_press)
	button_up.connect(_on_release)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size / 2.0

func _on_hover_enter() -> void:
	if disabled:
		return
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_hover_exit() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_OUT)

func _on_press() -> void:
	if disabled:
		return
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.93, 0.93), 0.07).set_ease(Tween.EASE_OUT)

func _on_release() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.07).set_ease(Tween.EASE_OUT)

# Statinis pagalbinis metodas – iššauk iš kitos scenos _ready() kad pritaikytum animaciją esamam mygtukui
static func apply_to(button: Button) -> void:
	button.pivot_offset = button.size / 2.0
	button.mouse_entered.connect(func():
		if button.disabled: return
		var tw = button.create_tween()
		tw.tween_property(button, "scale", Vector2(1.08, 1.08), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	)
	button.mouse_exited.connect(func():
		var tw = button.create_tween()
		tw.tween_property(button, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_OUT)
	)
	button.button_down.connect(func():
		if button.disabled: return
		var tw = button.create_tween()
		tw.tween_property(button, "scale", Vector2(0.93, 0.93), 0.07).set_ease(Tween.EASE_OUT)
	)
	button.button_up.connect(func():
		var tw = button.create_tween()
		tw.tween_property(button, "scale", Vector2(1.08, 1.08), 0.07).set_ease(Tween.EASE_OUT)
	)
