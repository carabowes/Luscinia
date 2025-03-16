class_name ResourceEntry
extends GridContainer

const CIRCLE_SIZE : Vector2 = Vector2(50, 50)
const ICON_SIZE : Vector2 = Vector2(30, 30)

@export_group("Resource info")
@export var resource_type : String
@export var amount : int
@export var increase : int = 0

@export_group("Visual")
@export var show_arrow : bool = true
@export var icon_color : Color
@export var text_color : Color
@export var circle_color : Color
@export var use_circle : bool:
	set(value):
		use_circle = value
		if use_circle:
			%IconContainer.custom_minimum_size = CIRCLE_SIZE
			%Circle.visible = true
			%ResourceIcon.reparent(%Circle, false)  # Move icon inside the circle
		else:
			%IconContainer.custom_minimum_size = ICON_SIZE
			%Circle.visible = false
			%ResourceIcon.reparent(%IconContainer, false)  # Move icon back to container
			%ResourceIcon.size = Vector2.ZERO  # Reset icon size
		queue_redraw()  # Redraw to reflect changes


# Called when the UI needs to be drawn or updated
func _draw() -> void:
	# Set resource amount text with formatted value
	%ResourceAmount.text = ResourceManager.format_resource_value(amount, 3)
	# Set the appropriate resource icon texture
	%ResourceIcon.texture = ResourceManager.get_resource_texture(resource_type)

	if increase == 0:
		%IncreaseIcon.visible = false
		%ResourceAmount.self_modulate = text_color
	elif increase > 0:
		%IncreaseIcon.visible = show_arrow
		%IncreaseColor.self_modulate = Color.LIME_GREEN
		%ResourceAmount.self_modulate = Color.LIME_GREEN
		%IncreaseIcon.rotation = 0  # Arrow pointing up
	else:
		%IncreaseIcon.visible = show_arrow
		%IncreaseColor.self_modulate = Color.RED
		%ResourceAmount.self_modulate = Color.RED
		%IncreaseIcon.flip_v = true  # Flip arrow to indicate decrease

	# Apply color settings to UI elements
	%ResourceIcon.self_modulate = icon_color
	%Circle.self_modulate = circle_color
