@tool
extends Line2D

var secs := 1000.0 # Big number so points looks like they've been wobbling around for a bit already

@export var points_intensity := 4.0
@export var whole_intensity := 0.5
@export var display_children_inherit_position := false
@export var clip_display_children := ClipChildrenMode.CLIP_CHILDREN_DISABLED
@export var speed := 1.0

var whole_wobble_off_seed : float
var whole_wobble_speed_seed : float

func _ready() -> void:
	whole_wobble_off_seed = randf_range(0, 100)
	whole_wobble_speed_seed = randf_range(0.5, 2.5)

	$DisplayLine.points = points

func _process(delta: float) -> void:
	$DisplayLine.points = points
	$DisplayLine.default_color = default_color
	$DisplayLine.antialiased = antialiased
	$DisplayLine.clip_children = clip_display_children
	$DisplayLine.width = width
	$DisplayLine.width_curve = width_curve
	$DisplayLine.joint_mode = joint_mode
	$DisplayLine.begin_cap_mode = begin_cap_mode
	$DisplayLine.end_cap_mode = end_cap_mode
	$DisplayLine.closed = closed

	for i in points.size():
		var point = points[i]
		var x_rate_off = sin(i) * 1
		var y_rate_off = cos(i) * 1

		var new_point_x = point.x + sin(secs * (2 + x_rate_off) + i) * points_intensity
		var new_point_y = point.y + cos(secs * (2 + y_rate_off) - i) * points_intensity

		if !display_children_inherit_position:
			new_point_x += sin(secs * (whole_wobble_speed_seed) + whole_wobble_off_seed) * whole_intensity
			new_point_y += cos(secs * (whole_wobble_speed_seed) + whole_wobble_off_seed) * whole_intensity
			$DisplayLine.position = Vector2.ZERO

		$DisplayLine.points[i] = Vector2(
			new_point_x,
			new_point_y
		)
		if display_children_inherit_position:
			$DisplayLine.position.x = sin(secs * (whole_wobble_speed_seed) + whole_wobble_off_seed) * whole_intensity
			$DisplayLine.position.y = cos(secs * (whole_wobble_speed_seed) + whole_wobble_off_seed) * whole_intensity

	secs += delta * speed
