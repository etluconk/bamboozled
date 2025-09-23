@tool
extends Node2D
class_name MoveFrame

@export var state_properties : StateProperties = StateProperties.new()

func _ready() -> void:
	pass

func get_move_frame_areas_of_type(area_type : MoveFrameArea.AreaType) -> Array[MoveFrameArea]:
	var arr : Array[MoveFrameArea] = []
	for child in get_children():
		if child is MoveFrameArea:
			if child.area_type == area_type:
				arr.append(child)
	return arr

func get_character() -> Character:
	if get_parent() is not MoveFrameData: return null
	if get_parent().get_parent() is not FrameDataSystem: return null
	if get_parent().get_parent().get_parent() is not Character: return null
	return get_parent().get_parent().get_parent()
