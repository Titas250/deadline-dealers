extends PanelContainer

var card_value: int = 0
var suit_index: int = 0
var is_hidden: bool = false

var _texture_rect: TextureRect
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

	_texture_rect = TextureRect.new()
	_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_texture_rect)

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
	if not _texture_rect:
		return
	if is_hidden:
		_style.bg_color = Color(0.18, 0.22, 0.55)
		_texture_rect.texture = load("res://Assets/Images/Cards/card_back.png")
	else:
		_style.bg_color = Color.WHITE
		_texture_rect.texture = load("res://Assets/Images/Cards/card_" + str(suit_index) + "_" + str(card_value) + ".png")
