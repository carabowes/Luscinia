extends GraphEdit

@export var scenario_to_edit : Scenario
var saves : Array[EditorSave]

var task_nodes : Dictionary
var requisite_nodes : Array[RequisiteGraphNode]
var message_nodes : Array[MessageGraphNode]
var response_nodes : Array[ResponseGraphNode]
var sender_nodes : Array[SenderGraphNode]
var unique_senders : Dictionary

func _ready():
	set_resolution()
	load_saves_from_dir()
	load_scenario(scenario_to_edit)
	connect_requisites()
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnect_request)
	connection_from_empty.connect(_on_connection_from_empty)
	connection_to_empty.connect(_on_connection_to_empty)
	delete_nodes_request.connect(_on_deletion_request)
	link_buttons()
	%SaveButton.pressed.connect(save_scenario)


func set_resolution():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	get_window().size = DisplayServer.screen_get_size(DisplayServer.get_primary_screen())/2


func link_buttons():
	%NewTask.pressed.connect(func(): create_node(TaskData.new, add_task))
	%NewMessage.pressed.connect(func(): create_node(Message.new, add_message_node))
	%NewPrereq.pressed.connect(func(): create_node(Prerequisite.new, add_requisite))
	%NewResponse.pressed.connect(func(): create_node(Response.new, add_response))
	%NewSender.pressed.connect(select_sender)


func load_saves_from_dir(path = "res://TaskData/EditorSaves"):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		saves.append(load(path + "/" + file_name))
	dir.list_dir_end()


func load_scenario(scenario : Scenario):
	add_message_nodes(scenario.messages)
	for save in saves:
		if save.scenario == scenario:
			load_save(save)
			break


func load_save(save : EditorSave):
	print("Loading from save")
	zoom = save.zoom
	scroll_offset = save.scroll_offset
	for node_name in save.node_positions.keys():
		var node = get_node_or_null(node_name)
		if node != null:
			node.position_offset = save.node_positions[node_name]


func select_sender():
	var popup : PopupMenu = PopupMenu.new()
	for sender in unique_senders:
		popup.add_item(sender.name)
	popup.add_item("New Sender")
	popup.title = "Add a new sender or select existing"
	popup.borderless = false
	add_child(popup)
	popup.popup_centered_ratio(0.6)
	popup.index_pressed.connect(sender_selected)


func sender_selected(index : int):
	var sender_node
	if index == len(unique_senders):
		sender_node = create_node(Sender.new, add_sender)
	else:
		sender_node = create_node(func(): return unique_senders.keys()[index], add_sender)


func add_to_task_nodes(task_node : TaskGraphNode):
	task_nodes[task_node.task.task_id] = task_node


func remove_from_task_node(task_node : TaskGraphNode):
	task_nodes.erase(task_node.task.task_id)


func setup_node(node : TaskEditorGraphNode, list_function : Callable, list_deletion_function : Callable):
	node.name = "GraphNode"
	list_function.call(node)
	add_child(node)
	node.deleted.connect(func(): remove_all_connections(node); list_deletion_function.call(node))


func create_node(data_function : Callable, node_function : Callable, connect_node : TaskEditorGraphNode = null) -> GraphNode:
	var new_data = data_function.call()
	var node : TaskEditorGraphNode
	if new_data is Message:
		node = node_function.call(new_data)
	else:
		node = node_function.call(new_data, connect_node)
	center_node(node)
	set_selected(node)
	return node


func center_node(node : GraphNode):
	node.position_offset = (scroll_offset + size / 2) / zoom - node.size / 2;


func add_message_nodes(messages : Array[Message]):
	var task_section_size = Vector2(3500, 3000)
	var current_cell = Vector2(0,0)
	for message in messages:
		var node = add_message_node(message, current_cell * task_section_size, true)
		current_cell.x += 1
		if current_cell.x >= 5:
			current_cell.x = 0
			current_cell.y += 1


func add_message_node(message : Message = Message.new(), pos : Vector2 = Vector2.ZERO, from_load : bool = false) -> MessageGraphNode:
	var message_node : MessageGraphNode = MessageGraphNode.new(message)
	setup_node(message_node, message_nodes.append, message_nodes.erase)
	message_node.position_offset = pos
	if from_load:
		add_sender(message.sender, message_node, true)
		add_responses(message.responses, message_node, true)
		add_requisites(message.prerequisites, message_node, MessageGraphNode.InPortNums.PREREQUISITES, true)
		add_requisites(message.antirequisites, message_node, MessageGraphNode.InPortNums.ANTIREQUISITES, true)
	return message_node


func add_sender(sender : Sender = null, message_node : MessageGraphNode = null, from_load : bool = false) -> SenderGraphNode:
	if sender == null:
		return

	var sender_node : SenderGraphNode = SenderGraphNode.new(sender)
	setup_node(sender_node, sender_nodes.append, sender_nodes.erase)
	sender_node.information_updated.connect(
		func(node_changed):
			for node in sender_nodes:
				if node != node_changed:
					node.update()
	)
	unique_senders[sender] = true

	if message_node != null:
		connect_node(sender_node.name, SenderGraphNode.OutPortNums.MESSAGE, message_node.name, MessageGraphNode.InPortNums.SENDER)
	if from_load:
		sender_node.position_offset = message_node.position_offset - Vector2(400, 100)
	return sender_node


func add_responses(responses : Array[Response], message_node : MessageGraphNode, from_load : bool = false):
	var current_y = 0
	var start_y = -500 * floor(len(responses)/2)
	var pos = Vector2.ZERO
	for response : Response in responses:
		if message_node != null:
			pos = message_node.position_offset + Vector2(800, start_y + current_y * (700))
			current_y += 1
		var response_node : ResponseGraphNode = add_response(response, message_node, from_load, pos)


func add_response(response : Response = Response.new(), connect_node : TaskEditorGraphNode = null, from_load : bool = false, pos : Vector2 = Vector2.ZERO) -> ResponseGraphNode:
	var response_node : ResponseGraphNode = ResponseGraphNode.new(response)
	setup_node(response_node, response_nodes.append, response_nodes.erase)
	if from_load:
		response_node.position_offset = pos
	if connect_node is MessageGraphNode:
		connect_node(connect_node.name, MessageGraphNode.OutPortNums.RESPONSES, response_node.name, ResponseGraphNode.InPortNums.MESSAGE)
	if connect_node is TaskGraphNode:
		connect_node(response_node.name, ResponseGraphNode.OutPortNums.TASK, connect_node.name, TaskGraphNode.InPortNums.RESPONSE)
	if response.task != null:
		add_task(response.task, response_node, from_load)
	return response_node


func add_task(task : TaskData = TaskData.new(), connect_node : TaskEditorGraphNode = null, from_load : bool = false) -> TaskGraphNode:
	var task_node : TaskGraphNode = TaskGraphNode.new(task)
	setup_node(task_node, add_to_task_nodes, remove_from_task_node)
	if from_load:
		task_node.position_offset = connect_node.position_offset + Vector2(800, 0)
	if connect_node is ResponseGraphNode:
		connect_node(connect_node.name, ResponseGraphNode.OutPortNums.TASK, task_node.name, TaskGraphNode.InPortNums.RESPONSE)
	elif connect_node is RequisiteGraphNode:
		connect_node(task_node.name, TaskGraphNode.OutPortNums.PREREQ, connect_node.name, RequisiteGraphNode.InPortNums.TASK)
	return task_node


func add_requisites(requisites : Array[Prerequisite], message_node : MessageGraphNode, port_num, from_load = false):
	var x_offset = 800
	if port_num == MessageGraphNode.InPortNums.ANTIREQUISITES:
		x_offset = 1200
	var current_y = 0
	for requisite : Prerequisite in requisites:
		var requisite_node = add_requisite(requisite, message_node, port_num == MessageGraphNode.InPortNums.ANTIREQUISITES, from_load)
		requisite_node.position_offset = message_node.position_offset - Vector2(x_offset, -current_y * (requisite_node.size.y + 50))
		current_y += 1


func add_requisite(requisite : Prerequisite = Prerequisite.new(), connect_node : TaskEditorGraphNode = null, is_antirequisite : bool = false, from_load : bool = false) -> RequisiteGraphNode:
	var requisite_node : RequisiteGraphNode = RequisiteGraphNode.new(requisite)
	setup_node(requisite_node, requisite_nodes.append, requisite_nodes.erase)
	if connect_node is MessageGraphNode:
		var port_num = MessageGraphNode.InPortNums.ANTIREQUISITES if is_antirequisite else MessageGraphNode.InPortNums.PREREQUISITES
		connect_node(requisite_node.name, RequisiteGraphNode.OutPortNums.MESSAGE, connect_node.name, port_num)
	elif connect_node is TaskGraphNode:
		connect_node(connect_node.name, TaskGraphNode.OutPortNums.PREREQ, requisite_node.name, RequisiteGraphNode.InPortNums.TASK)
	return requisite_node


func connect_requisites():
	for node in requisite_nodes:
		for task in node.prerequisite.task_id:
			if task_nodes.has(task):
				var task_node = task_nodes[task]
				connect_node(task_node.name, TaskGraphNode.OutPortNums.PREREQ, node.name, RequisiteGraphNode.InPortNums.TASK)


func force_one_input_connection(to_node : String, to_port : int):
	for connection in get_connection_list():
		if connection.to_node == to_node and connection.to_port == to_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			return


func force_one_output_connection(from_node : String, from_port : int):
	for connection in get_connection_list():
		if connection.from_node == from_node and connection.from_port == from_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			return


func _on_connection_request(from_node : String, from_port : int, to_node : String, to_port : int):
	var input_node : TaskEditorGraphNode = get_node(from_node)
	var output_node : TaskEditorGraphNode = get_node(to_node)
	var sucessful_connection = output_node.assign_connection(to_port, input_node)
	if not sucessful_connection:
		return
	if input_node is SenderGraphNode and output_node is MessageGraphNode:
		force_one_input_connection(to_node, to_port)
	if input_node is ResponseGraphNode and output_node is TaskGraphNode:
		force_one_output_connection(from_node, from_port)
	connect_node(from_node, from_port, to_node, to_port)


func _on_connection_from_empty(to_node : String, to_port : int, release_position : Vector2):
	var output_node : TaskEditorGraphNode = get_node(to_node)
	var node_type = output_node.create_node_to_connect_from_empty(to_port)
	var new_node : GraphNode
	if node_type is RequisiteGraphNode:
		new_node = create_node(Prerequisite.new, add_requisite)
		if to_port == MessageGraphNode.InPortNums.PREREQUISITES:
			_on_connection_request(new_node.name, RequisiteGraphNode.OutPortNums.MESSAGE, output_node.name, MessageGraphNode.InPortNums.PREREQUISITES)
		else:
			_on_connection_request(new_node.name, RequisiteGraphNode.OutPortNums.MESSAGE, output_node.name, MessageGraphNode.InPortNums.ANTIREQUISITES)
	elif node_type is TaskGraphNode:
		new_node = create_node(TaskData.new, add_task, output_node)
	elif node_type is SenderGraphNode:
		select_sender()
	elif node_type is MessageGraphNode:
		new_node = create_node(Message.new, add_message_node, output_node)
		_on_connection_request(new_node.name, MessageGraphNode.OutPortNums.RESPONSES, output_node.name, ResponseGraphNode.InPortNums.MESSAGE)
	elif node_type is ResponseGraphNode:
		new_node = create_node(Response.new, add_response, output_node)
	if new_node != null:
		new_node.position_offset = (scroll_offset + release_position)/zoom - (Vector2(new_node.size.x/2, new_node.size.y/2))


func _on_connection_to_empty(from_node : String, from_port : int, release_position: Vector2):
	var input_node : TaskEditorGraphNode = get_node(from_node)
	var node_type = input_node.create_node_to_connect_to_empty(from_port)
	var new_node : GraphNode
	if node_type is RequisiteGraphNode:
		new_node = create_node(Prerequisite.new, add_requisite, input_node)
	elif node_type is TaskGraphNode:
		new_node = create_node(TaskData.new, add_task)
		_on_connection_request(input_node.name, ResponseGraphNode.OutPortNums.TASK, new_node.name, TaskGraphNode.InPortNums.RESPONSE)
	elif node_type is SenderGraphNode:
		select_sender()
	elif node_type is MessageGraphNode:
		new_node = create_node(Message.new, add_message_node)
		if input_node is SenderGraphNode:
			_on_connection_request(input_node.name, SenderGraphNode.OutPortNums.MESSAGE, new_node.name, MessageGraphNode.InPortNums.SENDER)
	elif node_type is ResponseGraphNode:
		new_node = create_node(Response.new, add_response)
		_on_connection_request(input_node.name, MessageGraphNode.OutPortNums.RESPONSES, new_node.name, ResponseGraphNode.InPortNums.MESSAGE)
	if new_node != null:
		new_node.position_offset = (scroll_offset + release_position)/zoom - (Vector2(new_node.size.x/2, new_node.size.y/2))


func _on_disconnect_request(from_node : String, from_port : int, to_node : String, to_port : int):
	var input_node : TaskEditorGraphNode = get_node(from_node)
	var output_node : TaskEditorGraphNode = get_node(to_node)
	var successful_disconnect = output_node.remove_connection(to_port, input_node)
	if not successful_disconnect:
		return
	disconnect_node(from_node, from_port, to_node, to_port)


func _on_deletion_request(nodes : Array[StringName]):
	for node_name in nodes:
		var element = get_node(NodePath(node_name))
		if element is GraphFrame:
			element.queue_free()
			continue
		var node : TaskEditorGraphNode = element
		node.delete_node()


func remove_all_connections(node: TaskEditorGraphNode):
	for connection in get_connection_list():
		if node.name == connection["from_node"] or node.name == connection["to_node"]:
			print("Disconnecting node")
			_on_disconnect_request(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])


func save_editor_state(editor_save: EditorSave, scenario : Scenario) -> EditorSave:
	if editor_save == null:
		editor_save = EditorSave.new(scenario, {}, zoom, scroll_offset)
	else:
		editor_save.zoom = zoom
		editor_save.scroll_offset = scroll_offset
		editor_save.node_positions.clear()
	for node in get_children():
		if node is GraphElement:
			editor_save.node_positions[node.name] = node.position_offset
		else:
			print(node.get_index(), node)
	return editor_save


func save_scenario():
	var messages : Array[Message]
	for message_node : MessageGraphNode in message_nodes:
		messages.append(message_node.message)
	scenario_to_edit.messages = messages
	print("Saving...")
	var result = ResourceSaver.save(scenario_to_edit)
	print("Saved with result of ", result)
	
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	var editor_save = null
	var existing_save = false
	for save in saves:
		if save.scenario == scenario_to_edit:
			editor_save = save
			existing_save = true
	editor_save = save_editor_state(editor_save, scenario_to_edit)
	if not existing_save:
		ResourceSaver.save(editor_save, "res://TaskData/EditorSaves/" + str(randi()) + ".tres")
	else:
		ResourceSaver.save(editor_save)
