@tool

extends Area2D
class_name Room

@export_range(0.0, 5120, 10) var width := 320.0
@export_range(0.0, 2880, 10) var height := 180.0

@onready var room_bounds_outline = $RoomBoundsOutline

func _ready() -> void:
	if !Engine.is_editor_hint():
		room_bounds_outline.hide()
		update_colliders_and_debug()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_colliders_and_debug()

func update_colliders_and_debug():
	var collision_shape = get_node_or_null("CollisionShape2D")
	var dimensions = Vector2(width, height)
	var center = dimensions / 2

	if collision_shape is CollisionShape2D:
		if !(collision_shape.shape is RectangleShape2D) or collision_shape.position != center:
			collision_shape.position = center
			collision_shape.shape = RectangleShape2D.new()
		collision_shape.debug_color = Color(Color.from_hsv(sin(position.x * 0.001 - position.y * 0.001) + 100, 1, 1), 0.3)

		if collision_shape.shape.size != dimensions:
			collision_shape.shape.size = dimensions

		room_bounds_outline.points = [
			Vector2(0, 0),
			Vector2(dimensions.x, 0),
			Vector2(dimensions.x, dimensions.y),
			Vector2(0, dimensions.y)
		]
		room_bounds_outline.default_color = Color(collision_shape.debug_color, 0.7)
		room_bounds_outline.position = position
