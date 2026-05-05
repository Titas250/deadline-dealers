extends PanelContainer

# SCRUM-278: Vizualūs kortų komponentai
# SCRUM-281: Žalio veltinio stalviršio integracija
# Naudojimas Blackjack.gd:
#   var CardScript = preload("res://Scripts/Blackjack/Card.gd")
#   var card = PanelContainer.new()
#   card.set_script(CardScript)
#   container.add_child(card)
#   card.setup(value, suit)   # suit: 0=♠ 1=♥ 2=♦ 3=♣

const SUITS := ["♠", "♥", "♦", "♣"]

var card_value: int = 0
var suit_index: int = 0
var is_hidden: bool = false

var _value_label: Label
var _suit_label: Label
var _style: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = Vector2(78, 112)
	_style = StyleBoxFlat.new()
	_style.bg_color = Color.WHITE
	_style.corner_radius_top_left = 8
	_style.corner_radius_top_right = 8
	_style.corner_radius_bottom_left = 8
	_style.corner_radius_bottom_right = 8
	_style.shadow_color = Color(0, 0, 0, 0.5)
	_style.shadow_size = 5
	_style.shadow_offset = Vector2(2, 3)
	add_theme_stylebox_override("panel", _style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	add_child(vbox)

	_value_label = Label.new()
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_value_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(_value_label)

	_suit_label = Label.new()
	_suit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_suit_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(_suit_label)

	_update_display()

func setup(value: int, suit: int, hidden: bool = false) -> void:
	card_value = value
	suit_index = suit
	is_hidden = hidden
	if is_inside_tree():
		_update_display()

func reveal() -> void:
	is_hidden = false
	_update_display()

func _update_display() -> void:
	if not _value_label or not _suit_label:
		return

	if is_hidden:
		_style.bg_color = Color(0.18, 0.22, 0.55)
		_value_label.text = "?"
		_suit_label.text = "🂠"
		_value_label.add_theme_color_override("font_color", Color.WHITE)
		_suit_label.add_theme_color_override("font_color", Color.WHITE)
		return

	_style.bg_color = Color.WHITE

	var display_val := ""
	match card_value:
		1:  display_val = "A"
		11: display_val = "J"
		12: display_val = "Q"
		13: display_val = "K"
		_:  display_val = str(card_value)

	_value_label.text = display_val
	_suit_label.text = SUITS[suit_index]

	var is_red := suit_index in [1, 2]
	var col := Color(0.78, 0.1, 0.1) if is_red else Color(0.07, 0.07, 0.07)
	_value_label.add_theme_color_override("font_color", col)
	_suit_label.add_theme_color_override("font_color", col)
