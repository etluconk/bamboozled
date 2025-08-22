@tool
extends Node2D
class_name MoveFrameData

@export var progress : int = 0:
	set(value):
		progress = value
		progress_changed.emit()

signal progress_changed

func _ready() -> void:
	pass

func get_active_move_frame_shapes_of_type(shape_type : MoveFrameShape.ShapeType) -> Array[MoveFrameShape]:
	if progress > get_child_count() - 1: return []

	var active_move_frame = get_children()[progress]
	if active_move_frame is MoveFrame:
		return active_move_frame.get_move_frame_shapes_of_type(shape_type)
	else:
		return []

func show_active_move_frame_shapes() -> void:
	for i in get_children().size():
		var child = get_children()[i]
		if i == progress:
			child.show()
		else:
			child.hide()
