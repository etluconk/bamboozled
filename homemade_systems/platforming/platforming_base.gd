extends Component
class_name PlatformingBaseComponent

func horizontal_input_direction() -> float:
	if get_player_idx() == -1: return 0
	return int(Input.is_action_pressed("right_" + str(get_player_idx()))) - int(Input.is_action_pressed("left_" + str(get_player_idx())))

func player_input_just_pressed(input_action_name : String) -> bool:
	if get_player_idx() == -1: return false
	return Input.is_action_just_pressed(input_action_name + "_" + str(get_player_idx()))

func player_input_pressed(input_action_name : String) -> bool:
	if get_player_idx() == -1: return false
	return Input.is_action_pressed(input_action_name + "_" + str(get_player_idx()))

func get_player_idx() -> int:
	var p = get_parent()
	if p is Character:
		return p.player_idx
	else:
		return -1
