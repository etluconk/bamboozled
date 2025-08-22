extends Camera2D

@export var source_player : CharacterBody2D

func _ready() -> void:
	if source_player != null:
		position = source_player.position
		limit_smoothed = source_player.self_camera.limit_smoothed
		limit_left = source_player.self_camera.limit_left
		limit_right = source_player.self_camera.limit_right
		limit_top = source_player.self_camera.limit_top
		limit_bottom = source_player.self_camera.limit_bottom

func _physics_process(_delta: float) -> void:
	if source_player != null:
		position_smoothing_enabled = source_player.self_camera.position_smoothing_enabled
		position_smoothing_speed = source_player.self_camera.position_smoothing_speed
		position = source_player.position
		limit_left = source_player.self_camera.limit_left
		limit_right = source_player.self_camera.limit_right
		limit_top = source_player.self_camera.limit_top
		limit_bottom = source_player.self_camera.limit_bottom
