class_name TaskEditorGraphNode
extends GraphNode

signal deleted

enum SlotType {
	PREQ_TO_MESSAGE,
	RESPONSE_TO_TASK,
	MESSAGE_TO_RESPONSE,
	SENDER_TO_MESSAGE,
	TASK_TO_PREQ
}

static var collapsible_container_prefab = preload("res://Scenes/Editor/collapsable_container.tscn")
static var field_prefab = preload("res://Scenes/Editor/field.tscn")
static var image_selector_prefab = preload("res://Scenes/Editor/image_selector.tscn")
static var choice_picker_prefab = preload("res://Scenes/Editor/choice_picker.tscn")
static var vector_input_prefab = preload("res://Scenes/Editor/vector_input.tscn")


var slot_colors = [
	Color.REBECCA_PURPLE,
	Color.DODGER_BLUE,
	Color.DARK_ORANGE,
	Color.GREEN_YELLOW,
	Color.FIREBRICK
]


func _init():
	resizable = true
	custom_minimum_size.x = 300
	add_delete_button()
	set_node_theme(self)


# Adds a delete button to the node, which allows for node deletion
func add_delete_button():
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(delete_button)
	delete_button.pressed.connect(delete_node)


# Deletes the node and emits a signal
func delete_node():
	queue_free()
	deleted.emit()


# Sets the theme for the node based on its type (Task, Message, etc.)
func set_node_theme(node: GraphNode):
	var theme : StyleBoxFlat = node.get_theme_stylebox("titlebar").duplicate()
	if node is TaskGraphNode:
		theme.bg_color = Color.FIREBRICK
	elif node is MessageGraphNode:
		theme.bg_color = Color.CORNFLOWER_BLUE
	elif node is RequisiteGraphNode:
		theme.bg_color = Color.REBECCA_PURPLE
	elif node is SenderGraphNode:
		theme.bg_color = Color.YELLOW_GREEN
	elif node is ResponseGraphNode:
		theme.bg_color = Color.ORANGE
	node.add_theme_stylebox_override("titlebar", theme)


# Placeholder for assigning connections between nodes
func assign_connection(_in_port: int, _in_node: TaskEditorGraphNode) -> bool:
	return false


# Placeholder for removing connections between nodes
func remove_connection(_in_port: int, _in_node: TaskEditorGraphNode) -> bool:
	return false


# Placeholder function for creating a node to connect from an empty port
func create_node_to_connect_from_empty(_in_port: int):
	return null


# Placeholder function for creating a node to connect to an empty port
func create_node_to_connect_to_empty(_out_port: int):
	return null

#region Add Inputs


# Adds an input field to the node with a heading and current value
func add_input(heading: String, current_value: String) -> LineEdit:
	var label = Label.new()
	label.text = heading
	add_child(label)
	var input = LineEdit.new()
	input.text = current_value
	add_child(input)
	return input


# Adds a larger input field (TextEdit) with a heading and current value
func add_large_input(heading: String, current_value: String) -> TextEdit:
	var label = Label.new()
	label.text = heading
	add_child(label)
	var input = TextEdit.new()
	input.text = current_value
	input.custom_minimum_size.y = 200
	input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	input.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(input)
	return input


# Adds an image selector to the node with a heading and a texture
func add_image_selector(heading: String, texture: Texture) -> ImageSelector:
	var image_selector: ImageSelector = image_selector_prefab.instantiate()
	image_selector.current_image = texture
	image_selector.text = heading
	add_child(image_selector)
	return image_selector


# Adds a collapsible container with a heading and an array of fields
func add_collapsible_container(heading: String, fields: Array[Field]) -> CollapsibleContainer:
	var collapsible_container: CollapsibleContainer = collapsible_container_prefab.instantiate()
	collapsible_container.text = heading
	for field in fields:
		collapsible_container.add_child(field)
	add_child(collapsible_container)
	collapsible_container.toggled.connect(func(): size.y = 0)
	return collapsible_container


# Adds a spacer control to the node, typically used for layout spacing
func add_spacer(size: int = 20) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size.y = size
	add_child(spacer)
	return spacer


# Adds a checkbox with a label and a default value
func add_checkbox(heading: String, default_value: bool) -> CheckBox:
	var checkbox = CheckBox.new()
	var label = Label.new()
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size.y = 30
	label.text = heading
	checkbox.set_pressed_no_signal(default_value)
	hbox.add_child(label)
	hbox.add_child(checkbox)
	hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	checkbox.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(hbox)
	return checkbox


# Adds a slider with a label, default value, min/max range, and step size
func add_slider(heading: String, default_value: float,\
	min_value: float, max_value: float, step: float = 0.01) -> Slider:
	var label = Label.new()
	var slider = HSlider.new()
	label.text = heading + ": " + str(default_value)
	slider.step = step
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = default_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label)
	add_child(slider)
	slider.value_changed.connect(func(value): label.text = heading + ": " + str(value))
	return slider


# Adds a choice picker with a heading and possible values, setting the default option
func add_choice_picker(heading: String, values: Dictionary, default_option) -> ChoicePicker:
	var choice_picker: ChoicePicker = choice_picker_prefab.instantiate()
	choice_picker.text = heading
	choice_picker.set_values(str(default_option), values)
	add_child(choice_picker)
	return choice_picker


# Adds a vector input field with a heading and default value
func add_vector_input(heading: String, default: Vector2) -> VectorInput:
	var vector_input: VectorInput = vector_input_prefab.instantiate()
	vector_input.heading = heading
	vector_input.value = default
	add_child(vector_input)
	return vector_input

#endregion


# Sets the connection port for the node, determining whether it's an input or output
func set_port(is_input: bool, index: int, slot_type: SlotType):
	var color = slot_colors[slot_type]
	if is_input:
		set_slot(index, true, slot_type, color, is_slot_enabled_right(index),\
		get_slot_type_right(index), get_slot_color_right(index))
	else:
		set_slot(index, is_slot_enabled_left(index), get_slot_type_left(index),\
		get_slot_color_left(index), true, slot_type, color)


# Generates fields from the available resources for the node
static func generate_fields_from_resources(resources: Dictionary) -> Array[Field]:
	var fields: Array[Field] = []
	for resource in ["funds", "people", "supplies", "vehicles"]:
		var field: Field = field_prefab.instantiate()
		field.field_name = resource
		if resources.has(resource):
			field.field_value = str(resources[resource])
		else:
			field.field_value = str(0)
		fields.append(field)
	return fields
