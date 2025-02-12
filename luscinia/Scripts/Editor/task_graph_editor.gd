extends GraphEdit

@export var scenario_to_edit : Scenario

var task_nodes : Dictionary
var requisite_nodes : Array[RequisiteGraphNode]
var message_nodes : Array[MessageGraphNode]
var response_nodes : Array[ResponseGraphNode]
var sender_nodes : Array[SenderGraphNode]
var unique_senders : Array[Sender]

func _ready():
	load_scenario(scenario_to_edit)
	arrange_nodes()
	connect_requisites()
	arrange_nodes()
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnect_request)
	link_buttons()
	%SaveButton.pressed.connect(save_scenario)


func link_buttons():
	
	var sender_creation = func(sender : Sender = null):
		if sender == null:
			sender = Sender.new() 
		var sender_node = SenderGraphNode.new(sender)
		sender_node.information_updated.connect(
			func(node_changed):
				for node in sender_nodes:
					if node != node_changed:
						node.reset())
		return sender_node
	
	var task_creation = func():
		var new_task = TaskData.new("CHANGE ME")
		return new_task
	
	%NewTask.pressed.connect(func(): add_node(task_creation, TaskGraphNode.new, add_to_task_nodes, remove_from_task_node))
	%NewMessage.pressed.connect(func(): add_node(Message.new, MessageGraphNode.new, message_nodes.append, message_nodes.erase))
	%NewPrereq.pressed.connect(func(): add_node(Prerequisite.new, RequisiteGraphNode.new, requisite_nodes.append, requisite_nodes.erase))
	%NewResponse.pressed.connect(func(): add_node(Response.new, ResponseGraphNode.new, response_nodes.append, response_nodes.erase))
	%NewSender.pressed.connect(select_sender)


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
		sender_node = load_sender(Sender.new(), null)
	else:
		sender_node = load_sender(unique_senders[index], null)
	center_node(sender_node)
	set_selected(sender_node)


func add_to_task_nodes(task_node : TaskGraphNode):
	task_nodes[task_node.task.task_id] = task_node


func remove_from_task_node(task_node : TaskGraphNode):
	task_nodes.erase(task_node.task.task_id)


func setup_node(node : TaskEditorGraphNode, list_function : Callable, list_deletion_function : Callable):
	list_function.call(node)
	add_child(node)
	node.deleted.connect(func(): list_deletion_function.call(node))


func add_node(data_function : Callable, node_function : Callable, list_function : Callable, list_deletion_function : Callable):
	var new_data = data_function.call()
	var node = node_function.call(new_data)
	setup_node(node, list_function, list_deletion_function)
	center_node(node)
	set_selected(node)


func center_node(node : GraphNode):
	node.position_offset = (scroll_offset + size / 2) / zoom - node.size / 2;


func load_scenario(scenario : Scenario):
	load_messages(scenario.messages)


func load_messages(messages : Array[Message]):
	for message in messages:
		var message_node : MessageGraphNode = MessageGraphNode.new(message)
		setup_node(message_node, message_nodes.append, message_nodes.erase)
		load_sender(message.sender, message_node)
		load_responses(message.responses, message_node)
		load_requisites(message.prerequisites, message_node, MessageGraphNode.InPortNums.PREREQUISITES)
		load_requisites(message.antirequisites, message_node, MessageGraphNode.InPortNums.ANTIREQUISITES)


func load_sender(sender : Sender, message_node : MessageGraphNode) -> SenderGraphNode:
	if sender == null:
		return
	var sender_node : SenderGraphNode = SenderGraphNode.new(sender)
	setup_node(sender_node, sender_nodes.append, sender_nodes.erase)
	sender_node.information_updated.connect(func(node_changed):
		for node in sender_nodes:
			if node != node_changed:
				node.reset()
	)
	if not unique_senders.has(sender):
		unique_senders.append(sender)
	if message_node != null:
		connect_node(sender_node.name, SenderGraphNode.OutPortNums.MESSAGE, message_node.name, MessageGraphNode.InPortNums.SENDER)
	return sender_node


func load_responses(responses : Array[Response], message_node : MessageGraphNode):
	for response : Response in responses:
		var response_node : ResponseGraphNode = ResponseGraphNode.new(response)
		setup_node(response_node, response_nodes.append, response_nodes.erase)
		connect_node(message_node.name, MessageGraphNode.OutPortNums.RESPONSES, response_node.name, ResponseGraphNode.InPortNums.MESSAGE)
		if response.task != null:
			load_task(response.task, response_node)


func load_task(task : TaskData, response_node : ResponseGraphNode):
	var task_node : TaskGraphNode = TaskGraphNode.new(task)
	setup_node(task_node, add_to_task_nodes, remove_from_task_node)
	connect_node(response_node.name, ResponseGraphNode.OutPortNums.TASK, task_node.name, TaskGraphNode.InPortNums.RESPONSE)


func load_requisites(prerequisites : Array[Prerequisite], message_node : MessageGraphNode, port_num):
	for prerequisite : Prerequisite in prerequisites:
		var prereq_node : RequisiteGraphNode = RequisiteGraphNode.new(prerequisite)
		setup_node(prereq_node, requisite_nodes.append, requisite_nodes.erase)
		connect_node(prereq_node.name, RequisiteGraphNode.OutPortNums.MESSAGE, message_node.name, port_num)


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


func _on_disconnect_request(from_node : String, from_port : int, to_node : String, to_port : int):
	var input_node : TaskEditorGraphNode = get_node(from_node)
	var output_node : TaskEditorGraphNode = get_node(to_node)
	var successful_disconnect = output_node.remove_connection(to_port, input_node)
	if not successful_disconnect:
		return
	disconnect_node(from_node, from_port, to_node, to_port)


func save_scenario():
	var messages : Array[Message]
	for message_node : MessageGraphNode in message_nodes:
		messages.append(message_node.message)
	scenario_to_edit.messages = messages
	print("Saving...")
	print(scenario_to_edit.resource_path)
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	var result = ResourceSaver.save(scenario_to_edit)
	print("Saved with result of ", result)
