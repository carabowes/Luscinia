class_name ResourceEntry
extends GridContainer

@export_group("Resource info")
@export var resource_type : String
@export var amount : int
@export var increase : int = 0
@export var show_arrow : bool = true

func _draw() -> void:
	%ResourceAmount.text = number_to_text(amount)
	%ResourceIcon.texture = ResourceManager.get_resource_texture(resource_type)
	if(increase == 0):
		%IncreaseIcon.visible = false
		%ResourceAmount.self_modulate = Color.DIM_GRAY
	elif(increase > 0):
		%IncreaseIcon.visible = show_arrow;
		%IncreaseIcon.self_modulate = Color.LIME_GREEN
		%ResourceAmount.self_modulate = Color.LIME_GREEN
		%IncreaseIcon.rotation = 0;
	else:
		%IncreaseIcon.visible = show_arrow;
		%IncreaseIcon.self_modulate = Color.RED
		%ResourceAmount.self_modulate = Color.RED
		%IncreaseIcon.flip_v = true;


func number_to_text(number : int) -> String:
	#There should be no good reason for the numbers to get any bigger than a 999 Million
	if number >= 1_000_000:
		return str(number / 1_000_000) + "M"
	if number >= 1_000:
		return str(number / 1_000) + "K"
	return str(number)
