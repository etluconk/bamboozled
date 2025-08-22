@tool
extends Node2D
class_name FrameDataSystem

@export var active_move_frame_data_name : String:
	set(value):
		active_move_frame_data_name = value
		update_frame_data()

@onready var hitbox = $%Hitbox
@onready var hurtbox = $%Hurtbox

func _ready() -> void:
	for child in get_children():
		if child is MoveFrameData:
			child.progress_changed.connect(update_frame_data)
			child.hide()

	if !Engine.is_editor_hint():
		hitbox.show()
		hurtbox.show()

func update_frame_data():
	duplicate_move_frame_shapes_to_area(MoveFrameShape.ShapeType.HITBOX)
	duplicate_move_frame_shapes_to_area(MoveFrameShape.ShapeType.HURTBOX)

	if Engine.is_editor_hint():
		focus_active_move_frame()

func duplicate_move_frame_shapes_to_area(shape_type : MoveFrameShape.ShapeType):
	var target_area : Area2D
	match shape_type:
		MoveFrameShape.ShapeType.HITBOX: target_area = hitbox
		MoveFrameShape.ShapeType.HURTBOX: target_area = hurtbox

	if target_area == null: return

	free_all_children_of_node(target_area)

	var i := 0
	for move_frame_shape in get_active_move_frame_shapes_of_type(shape_type):
		var move_frame_shape_dupe : MoveFrameShape = move_frame_shape.duplicate()
		move_frame_shape_dupe.show()
		move_frame_shape_dupe.name = "_FDS_Move_Frame_Shape_" + str(i)

		target_area.add_child(move_frame_shape_dupe)
		move_frame_shape_dupe.owner = get_tree().edited_scene_root
		i += 1

func free_all_children_of_node(node : Node):
	if !node: return
	for child in node.get_children():
		child.free()

func get_active_move_frame_shapes_of_type(shape_type : MoveFrameShape.ShapeType) -> Array[MoveFrameShape]:
	var active_move_frame_data = get_node_or_null(active_move_frame_data_name)

	if active_move_frame_data != null:
		return active_move_frame_data.get_active_move_frame_shapes_of_type(shape_type)
	else:
		return []

func focus_active_move_frame() -> void:
	var active_move_frame_data = get_node_or_null(active_move_frame_data_name)
	for child in get_children():
		if child is MoveFrameData:
			if child == active_move_frame_data:
				child.show()
				child.show_active_move_frame_shapes()
			else:
				child.hide()
