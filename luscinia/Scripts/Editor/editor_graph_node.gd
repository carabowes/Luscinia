class_name TaskEditorGraphNode
extends GraphNode

signal deleted

var collapsible_container_prefab = preload("res://Scenes/UI/collapsable_container.tscn")
var field_prefab = preload("res://Scenes/Editor/field.tscn")
var image_selector_prefab = preload("res://Scenes/Editor/image_selector.tscn")
var choice_picker_prefab = preload("res://Scenes/Editor/choice_picker.tscn")

enum SlotType {
	PREQ_TO_MESSAGE,
	RESPONSE_TO_TASK,
	MESSAGE_TO_RESPONSE,
	SENDER_TO_MESSAGE,
	TASK_TO_PREQ
}

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
	set_node_theme(self)
	var delete_button = Button.new()
	delete_button.text = "X"
	delete_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(delete_button)
	delete_button.pressed.connect(func(): queue_free(); deleted.emit())


func add_input(heading : String, current_value : String) -> LineEdit:
	var label = Label.new()
	label.text = heading
	add_child(label)
	var input = LineEdit.new()
	input.text = current_value
	add_child(input)
	return input


func add_large_input(heading : String, current_value : String) -> TextEdit:
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


func add_image_selector(heading: String, texture : Texture) -> ImageSelector:
	var image_selector : ImageSelector = image_selector_prefab.instantiate()
	image_selector.current_image = texture
	image_selector.text = heading
	add_child(image_selector)
	return image_selector


func generate_fields_from_resources(resources : Dictionary) -> Array[Field]:
	var fields : Array[Field] = []
	for resource in ResourceManager.resources.keys():
		var field : Field = field_prefab.instantiate()
		field.field_name = resource
		if resources.has(resource):
			field.field_value = str(resources[resource])
		else:
			field.field_value = str(0)
		fields.append(field)
	return fields


func add_collapsible_container(heading : String, fields : Array[Field])  -> CollapsibleContainer:
	var collapsible_container : CollapsibleContainer = collapsible_container_prefab.instantiate()
	collapsible_container.text = heading
	for field in fields:
		collapsible_container.add_child(field)
	add_child(collapsible_container)
	collapsible_container.toggled.connect(func(): size.y = 0)
	return collapsible_container


func add_spacer(size : int = 20) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size.y = size
	add_child(spacer)
	return spacer


func add_checkbox(heading: String, default_value : bool) -> CheckBox:
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


func add_slider(heading: String, default_value: float, min_value: float, max_value: float, step : float = 0.01) -> Slider:
	var label = Label.new()
	var slider = HSlider.new()
	label.text = heading +  ": " + str(default_value)
	slider.step = step
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = default_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label)
	add_child(slider)
	slider.value_changed.connect(func(value): label.text = heading + ": " + str(value))
	return slider


func add_choice_picker(heading: String, values : Dictionary, default_option) -> ChoicePicker:
	var choice_picker : ChoicePicker = choice_picker_prefab.instantiate()
	choice_picker.text = heading
	choice_picker.set_values(str(default_option), values)
	add_child(choice_picker)
	return choice_picker


func set_port(is_input : bool, i : int, slot_type : SlotType):
	var color = slot_colors[slot_type]
	if is_input:
		set_slot(i, true, slot_type, color, is_slot_enabled_right(i), get_slot_type_right(i), get_slot_color_right(i))
	else:
		set_slot(i, is_slot_enabled_left(i), get_slot_type_left(i), get_slot_color_left(i), true, slot_type, color)


func set_node_theme(node : GraphNode):
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


func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	return false


func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	return false


func create_node_to_connect_from_empty(in_port: int):
	return null


func create_node_to_connect_to_empty(out_port: int):
	return null
