@tool
extends Node2D
class_name MoveFrame

func _ready() -> void:
	pass

func get_move_frame_shapes_of_type(shape_type : MoveFrameShape.ShapeType) -> Array[MoveFrameShape]:
	var arr : Array[MoveFrameShape] = []
	for child in get_children():
		if child is MoveFrameShape:
			if child.shape_type == shape_type:
				arr.append(child)
	return arr
