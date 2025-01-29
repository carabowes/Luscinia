extends GridContainer
class_name ResourceEntry

@export_group("Resource info")
@export var resource_type : String
@export var amount : int
@export var increase : int = 0

func _draw() -> void:
	%ResourceAmount.text = str(amount)
	%ResourceIcon.texture = ResourceManager.get_resource_texture(resource_type)
	if(increase == 0):
		%IncreaseIcon.visible = false
		%ResourceAmount.self_modulate = Color.DIM_GRAY
	elif(increase > 0):
		%IncreaseIcon.visible = true;
		%IncreaseIcon.self_modulate = Color.LIME_GREEN
		%ResourceAmount.self_modulate = Color.LIME_GREEN
		%IncreaseIcon.rotation = 0;
	else:
		%IncreaseIcon.visible = true;
		%IncreaseIcon.self_modulate = Color.RED
		%ResourceAmount.self_modulate = Color.RED
		%IncreaseIcon.flip_v = true;
