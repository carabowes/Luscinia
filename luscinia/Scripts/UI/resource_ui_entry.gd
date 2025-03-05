class_name ResourceEntry
extends GridContainer

@export_group("Resource info")
@export var resource_type : String
@export var amount : int
@export var increase : int = 0
@export var show_arrow : bool = true

func _draw() -> void:
	%ResourceAmount.text = ResourceManager.format_resource_value(amount, 3)
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
