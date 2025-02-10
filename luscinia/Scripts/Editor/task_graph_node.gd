class_name TaskGraphNode
extends TaskEditorGraphNode

var task : TaskData

var change_task_id : Callable

enum InPortNums {
	RESPONSE = 0
}

enum OutPortNums {
	PREREQ = 0
}

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
	task_name_input.text_submitted.connect(_on_task_name_changed)
	
	var task_id_input = add_input("Task ID", str(task.task_id))
	set_port(false, task_id_input.get_index(), SlotType.TASK_TO_PREQ)
	task_id_input.text_submitted.connect(_on_task_id_changed)
	change_task_id = func(value): task_id_input.text = str(value); task.task_id = int(value)
	
	var task_time_input = add_input("Expected Completion Time", str(task.expected_completion_time))
	task_time_input.text_submitted.connect(_on_task_time_changed)
	
	var icon_selector : ImageSelector = add_image_selector("Task Icon", task.icon)
	icon_selector.image_selected.connect(_on_image_selected)
	
	var resources_required_fields : Array[Field] = generate_fields_from_resources(task.resources_required)
	for field in resources_required_fields:
		field.field_changed.connect(_on_resource_required_field_changed)
	add_collapsible_container("Resources Required", resources_required_fields)
	
	var resources_gained_fields : Array[Field] = generate_fields_from_resources(task.resources_gained)
	for field in resources_gained_fields:
		field.field_changed.connect(_on_resource_gained_field_changed)
	add_collapsible_container("Resources Gained", resources_gained_fields)


func _on_task_name_changed(new_name : String):
	task.name = new_name
	ResourceSaver.save(task)


func _on_task_id_changed(new_id : String):
	var id = int(new_id)
	if id == 0:
		return
	task.task_id = id
	ResourceSaver.save(task)


func _on_task_time_changed(new_time : String):
	if not new_time.is_valid_int():
		return
	task.expected_completion_time = int(new_time)
	ResourceSaver.save(task)


func _on_image_selected(image : Texture):
	task.icon = image
	ResourceSaver.save(task)


func _on_resource_required_field_changed(resource: String, new_resource : String):
	if not new_resource.is_valid_int():
		return
	if new_resource == "0" and task.resources_required.has(resource):
		task.resources_required.erase(resource)
	else:
		task.resources_required[resource] = int(new_resource)
	ResourceSaver.save(task)


func _on_resource_gained_field_changed(resource: String, new_resource : String):
	if not new_resource.is_valid_int():
		return
	if new_resource == "0" and task.resources_required.has(resource):
		task.resources_gained.erase(resource)
	else:
		task.resources_gained[resource] = int(new_resource)
	ResourceSaver.save(task)
