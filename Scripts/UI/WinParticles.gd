extends CPUParticles2D

# SCRUM-289: Laimėjimo konfeti efektas
# Pridėk CPUParticles2D nodą prie scenos (virš visko),
# priskirk šį script, tada iššauk play() laimėjus

func _ready() -> void:
	emitting = false
	amount = 120
	lifetime = 2.2
	explosiveness = 0.85
	spread = 60.0
	direction = Vector2(0, -1)
	gravity = Vector2(0, 300)
	initial_velocity_min = 250.0
	initial_velocity_max = 500.0
	angular_velocity_min = -180.0
	angular_velocity_max = 180.0
	scale_amount_min = 5.0
	scale_amount_max = 10.0
	color_ramp = _make_gradient()

func _make_gradient() -> Gradient:
	var g = Gradient.new()
	g.colors = [Color.GOLD, Color(1, 0.3, 0.3), Color(0.3, 0.6, 1), Color.LIME_GREEN]
	g.offsets = [0.0, 0.33, 0.66, 1.0]
	return g

func play() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 0.3).timeout
	emitting = false
