@tool
extends Node2D
class_name AnimationData

@export var multi_frame_count := 1
@export_tool_button("Add Frame", "Callable") var do_add_frame = add_frame
@export_tool_button("Add Empty Frame", "Callable") var do_add_empty_frame = add_empty_frame
@export_tool_button("Remove Last Frame", "Callable") var do_remove_last_frame = remove_last_frame

@export_category("Duplicate")
@export var frame_to_duplicate : FrameCollisionShape
@export_tool_button("Duplicate Frame", "Callable") var do_duplicate_frame = duplicate_frame

@export_category("Clearing")
@export_tool_button("Clear Frames", "Callable") var do_clear_frames = clear_frames
@export_tool_button("Hide All Frames", "Callable") var do_hide_all_frames = hide_all_frames
@export_tool_button("Cleanup Frame Names", "Callable") var do_cleanup_frame_names = cleanup_frame_names

@export_category("First off...")
@export var animation_player : AnimationPlayer
@export var animation_name := ""

@export_category("DON'T TOUCH THIS!")
@export var frame_data := []
@export var _initialized := false
@export var _anim_track_idx := -1

# Playback and Runtime variables
var active_frame_index = -1

func _ready():
	if Engine.is_editor_hint() and not _initialized:
		_initialized = true

	if !Engine.is_editor_hint():
		disable_all_frames()
		hide_all_frames()

func add_frame() -> void:
	var new_frame = []
	for i in multi_frame_count:
		var new_collision_shape = FrameCollisionShape.new()
		new_collision_shape.shape = RectangleShape2D.new()
		add_child(new_collision_shape)
		new_collision_shape.owner = get_tree().edited_scene_root
		new_frame.append(get_path_to(new_collision_shape))

	frame_data.append(new_frame)
	add_track_if_needed()
	cleanup_frame_names()
	multi_frame_count = 1

	only_show_index(frame_data.size() - 1)

func insert_frame(_index: int, tree_order_index: int) -> void:
	var new_frame = []
	var new_collision_shape = FrameCollisionShape.new()
	new_collision_shape.shape = RectangleShape2D.new()
	add_child(new_collision_shape)
	move_child(new_collision_shape, tree_order_index)
	new_collision_shape.owner = get_tree().edited_scene_root
	new_frame.append(get_path_to(new_collision_shape))

	frame_data.append(new_frame)
	add_track_if_needed()
	cleanup_frame_names()

	# only_show_index(index)

func add_empty_frame() -> void:
	var new_frame = []
	var new_collision_shape = FrameCollisionShape.new()
	add_child(new_collision_shape)
	new_collision_shape.owner = get_tree().edited_scene_root
	new_frame.append(get_path_to(new_collision_shape))

	frame_data.append(new_frame)
	add_track_if_needed()
	cleanup_frame_names()

	only_show_index(frame_data.size() - 1)

func duplicate_frame() -> void:
	if frame_to_duplicate == null:
		printerr("No frame to duplicate!")
		return

	var new_frame = []
	for i in multi_frame_count:
		var new_collision_shape = frame_to_duplicate.duplicate()
		add_child(new_collision_shape)
		new_collision_shape.owner = get_tree().edited_scene_root
		new_frame.append(get_path_to(new_collision_shape))

	frame_data.append(new_frame)
	add_track_if_needed()
	cleanup_frame_names()

	only_show_index(frame_data.size() - 1)

func clear_frames() -> void:
	for frame_index in frame_data:
		for child in frame_index:
			if get_node_or_null(child) is Node:
				get_node_or_null(child).queue_free()
	frame_data.clear()
	remove_track_if_needed()

func remove_last_frame() -> void:
	if frame_data.size() < 1: return

	for child in frame_data[frame_data.size() - 1]:
		if get_node_or_null(child) is Node:
			get_node_or_null(child).queue_free()
	frame_data.pop_back()
	remove_track_if_needed()

func cleanup_frame_names() -> void:
	var placeholder_idx = 0
	for child in get_children():
		child.name = str(placeholder_idx)
		placeholder_idx += 1

	var i = 0
	var j = 0
	var child_idx = 0
	for child in get_children():
		if frame_data[i].size() > 1 and j <= frame_data[i].size() - 1:
			child.name = str(i) + char(97 + j).capitalize() + "_Frame"
			frame_data[i][j] = get_path_to(child)
			j += 1
			if j == frame_data[i].size():
				j = 0
				i += 1
		else:
			j = 0
			if child.shape != null:
				child.name = str(i) + "_Frame"
				frame_data[i][j] = get_path_to(child)
			else:
				child.name = str(i) + "_Empty"
				frame_data[i][j] = get_path_to(child)
			if child_idx < get_child_count() - 1:
				i += 1

		child_idx += 1

# Animation Player

func add_track_if_needed() -> void:
	if _anim_track_idx == -1:
		var animation := animation_player.get_animation(animation_name)
		var path = str(get_node(animation_player.root_node).get_parent().get_path_to(self)) + ":active_frame_index"
		_anim_track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(_anim_track_idx, path)
		animation.value_track_set_update_mode(_anim_track_idx, Animation.UPDATE_DISCRETE)

		animation.track_insert_key(_anim_track_idx, 0.0, -1)

func remove_track_if_needed() -> void:
	if _anim_track_idx != -1 and frame_data.size() == 0:
		var animation := animation_player.get_animation(animation_name)
		animation.remove_track(_anim_track_idx)
		_anim_track_idx = -1

# Navigating

func hide_all_frames() -> void:
	for frame_index in frame_data:
		for child in frame_index:
			if get_node_or_null(child):
				get_node_or_null(child).hide()

func only_show_index(idx) -> void:
	hide_all_frames()
	for child in frame_data[idx]:
		if get_node_or_null(child):
			get_node_or_null(child).show()

# Runtime and Playback

func disable_all_frames() -> void:
	for frame_index in frame_data:
		for child in frame_index:
			if get_node_or_null(child):
				get_node_or_null(child).disabled = true

func begin() -> void:
	print("hello")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if animation_player != null and animation_name != "":
			var animation := animation_player.get_animation(animation_name)
			for track_idx in animation.get_track_count():
				if animation.track_get_path(track_idx) == get_node(animation_player.root_node).get_parent().get_path_to(self):
					_anim_track_idx = track_idx
