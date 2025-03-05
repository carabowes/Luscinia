class_name TaskGraphNode
extends TaskEditorGraphNode


enum InPortNums {
	RESPONSE = 0
}

enum OutPortNums {
	PREREQ = 0
}

var task : TaskData

func _init(task : TaskData):
	super()
	self.task = task
	title = "Task Node"

	var response_label = Label.new()
	response_label.text = "Response"
	add_child(response_label)
	set_port(true, response_label.get_index(), SlotType.RESPONSE_TO_TASK)

	add_spacer()

	var task_name_input = add_input("Task Name", task.name)
	task_name_input.text_changed.connect(_on_task_name_changed)

	var task_id_input = add_input("Task ID", str(task.task_id))
	task_id_input.text_changed.connect(func(text): _on_task_id_changed(text, task_id_input))
	if(task.task_id == ""):
		task_id_input.self_modulate = Color.RED
	else:
		task_id_input.self_modulate = Color.WHITE
	set_port(false, task_id_input.get_index(), SlotType.TASK_TO_PREQ)

	var task_time_input = add_input("Expected Completion Time", str(task.expected_completion_time))
	task_time_input.text_changed.connect(func(text): _on_task_time_changed(text, task_time_input))

	var icon_selector : ImageSelector = add_image_selector("Task Icon", task.icon)
	icon_selector.image_selected.connect(_on_image_selected)

	var vector_input : VectorInput = add_vector_input("Location", task.start_location)
	vector_input.value_changed.connect(func(new_location): task.start_location = new_location)

	var resources_required_fields : Array[Field] =\
	generate_fields_from_resources(task.resources_required)
	for field in resources_required_fields:
		field.field_changed.connect(func(resource_type, value):\
		_on_resource_required_field_changed(resource_type, value, field))
	add_collapsible_container("Resources Required", resources_required_fields)

	var resources_gained_fields : Array[Field] =\
	generate_fields_from_resources(task.resources_gained)
	for field in resources_gained_fields:
		field.field_changed.connect(func(resource_type, value):\
		_on_resource_gained_field_changed(resource_type, value, field))
	add_collapsible_container("Resources Gained", resources_gained_fields)


func _on_task_name_changed(new_name : String):
	task.name = new_name


func _on_task_id_changed(new_id : String, input : LineEdit):
	if new_id == "":
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	task.task_id = new_id


func _on_task_time_changed(new_time : String, input : LineEdit):
	if new_time == "":
		new_time = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	if not new_time.is_valid_int():
		input.text = str(task.expected_completion_time)
		return
	task.expected_completion_time = new_time.to_int()


func _on_image_selected(image : Texture):
	task.icon = image


func _on_resource_required_field_changed(resource: String, new_resource : String, input : Field):
	if new_resource == "": new_resource = "0"
	if not new_resource.is_valid_int():
		input.field_value = str(task.resources_required[resource])\
		if task.resources_required.has(resource) else "0"
		return
	if new_resource == "0" and task.resources_required.has(resource):
		task.resources_required.erase(resource)
		input.field_value = "0"
	else:
		task.resources_required[resource] = int(new_resource)


func _on_resource_gained_field_changed(resource: String, new_resource : String, input : Field):
	if not new_resource.is_valid_int():
		input.field_value = str(task.resources_gained[resource])\
		if task.resources_gained.has(resource) else "0"
		return
	if new_resource == "0" and task.resources_gained.has(resource):
		task.resources_gained.erase(resource)
		input.field_value = "0"
	else:
		task.resources_gained[resource] = int(new_resource)


func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.RESPONSE and in_node is ResponseGraphNode:
		in_node.response.task = task
	else:
		return false
	return true


func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.RESPONSE and in_node is ResponseGraphNode:
		in_node.response.task = null
	else:
		return false
	return true


func create_node_to_connect_from_empty(in_port: int):
	if in_port == InPortNums.RESPONSE:
		return ResponseGraphNode.new(Response.new())
	return null


func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.PREREQ:
		return RequisiteGraphNode.new(Prerequisite.new())
	return null
