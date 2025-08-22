extends Component
class_name PlatformingBaseComponent

@export var input_player_index_component : InputPlayerIdxComp

func horizontal_input_direction() -> float:
	return Input.get_axis("left_" + str(get_player_idx()), "right_" + str(get_player_idx()))

func player_input_just_pressed(input_action_name : String) -> bool:
	return Input.is_action_just_pressed(input_action_name + "_" + str(get_player_idx()))

func player_input_pressed(input_action_name : String) -> bool:
	return Input.is_action_pressed(input_action_name + "_" + str(get_player_idx()))

func get_player_idx() -> int:
	return input_player_index_component.player_idx
