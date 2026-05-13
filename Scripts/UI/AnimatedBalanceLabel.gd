extends Label

# SCRUM-288: Balanso skaitiklio animacija
# Naudojimas: pakeisk BalanceLabel script į šį,
# tada vietoj  label.text = ... naudok label.animate_to(new_value)

var _current: float = 0.0

func init_value(value: int) -> void:
	_current = float(value)
	text = "Balance: $" + str(value)

func animate_to(new_value: int) -> void:
	var tween = create_tween()
	tween.tween_method(_update_display, _current, float(new_value), 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)

func _update_display(value: float) -> void:
	_current = value
	text = "Balance: $" + str(int(value))
