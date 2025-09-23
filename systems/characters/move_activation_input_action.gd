@tool
extends Resource
class_name MoveActivationInputAction

var button : String
const BUTTONS = [
	"lp",
	"mp",
	"hp",
	"lk",
	"mk",
	"hk",
]

func _get_property_list() -> Array[Dictionary]:
	return [
		{
			name = "button",
			type = TYPE_STRING,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(BUTTONS),
		}
	]
