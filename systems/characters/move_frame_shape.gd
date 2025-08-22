@tool
extends CollisionShape2D
class_name MoveFrameShape

enum ShapeType {HITBOX, HURTBOX}
@export var shape_type = ShapeType.HITBOX:
	set(value):
		shape_type = value
		reset_debug_color(value)

func _ready() -> void:
	if Engine.is_editor_hint():
		reset_debug_color(shape_type)

func reset_debug_color(value) -> void:
	match value:
		ShapeType.HURTBOX:
			debug_color = Color("00a4506b")
		ShapeType.HITBOX:
			debug_color = Color("ff020b6b")
