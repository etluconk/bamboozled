extends Camera2D
class_name RoomCamera

# Trackers!
var prev_overlapping_room_count := 0
var prev_current_room : Room = null

signal room_changed

func _ready() -> void:
	prev_overlapping_room_count = $RoomDetector.get_overlapping_areas().size()
	if $RoomDetector.has_overlapping_areas():
		prev_current_room = $RoomDetector.get_overlapping_areas()[0]

func _process(_delta: float) -> void:
	update_camera_limits()

func update_camera_limits() -> void:
	if $RoomDetector.has_overlapping_areas():
		var room = $RoomDetector.get_overlapping_areas()[0]
		if room is Room:
			limit_left = room.position.x
			limit_top = room.position.y
			limit_right = room.position.x + room.width
			limit_bottom = room.position.y + room.height
		else:
			limit_left = -10000000
			limit_top = -10000000
			limit_right = 10000000
			limit_bottom = 10000000
	else:
		limit_left = -10000000
		limit_top = -10000000
		limit_right = 10000000
		limit_bottom = 10000000

	# var overlapping_room_count_changed = $RoomDetector.get_overlapping_areas().size() != prev_overlapping_room_count
	var current_room_changed := true
	if $RoomDetector.has_overlapping_areas():
		current_room_changed = $RoomDetector.get_overlapping_areas()[0] != prev_current_room
	else:
		current_room_changed = prev_current_room != null

	if current_room_changed:
		$RoomTransitionTimer.start()
		room_changed.emit()

	prev_overlapping_room_count = $RoomDetector.get_overlapping_areas().size()
	if $RoomDetector.has_overlapping_areas():
		prev_current_room = $RoomDetector.get_overlapping_areas()[0]
	else:
		prev_current_room = null

func is_transitioning() -> bool:
	if !enabled:
		return false
	else:
		return !$RoomTransitionTimer.is_stopped()
