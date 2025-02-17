extends GutTest

var image = preload("res://Sprites/icon.svg")
var requisite_node_instance : RequisiteGraphNode
var requisite : Prerequisite


func before_each():
	requisite = Prerequisite.new([], 0.5, [], 5, -1)
	requisite_node_instance = RequisiteGraphNode.new(requisite)
	add_child_autofree(requisite_node_instance)

# Prerequisite Node Layout
# 0 - Delete Button
# 1 - Tasks Label				- Slot open on Left
# 2 - Chance Label
# 3 - Chance Slider
# 4 - Min Turn Label
# 5 - Min Turn
# 6 - Max Turn Label
# 7 - Max Turn
# 8 - Output Label				- Slot open on Right
func test_init():
	assert_eq(requisite_node_instance.prerequisite, requisite)
	
	assert_eq(requisite_node_instance.title, "Requisite Node")
	assert_is(requisite_node_instance.get_child(1), Label, "First child should be Label")
	assert_eq(requisite_node_instance.get_child(1).text, "Tasks")
	
	assert_is(requisite_node_instance.get_child(2), Label, "Second child should be Label")
	assert_eq(requisite_node_instance.get_child(2).text, "Chance: 0.5", "Chance label not being set correctly")
	
	assert_is(requisite_node_instance.get_child(3), HSlider, "Third child should be Slider")
	assert_eq(requisite_node_instance.get_child(3).value, 0.5, "Chance slider value not being set")
	assert_connected(requisite_node_instance.get_child(3), requisite_node_instance, "value_changed", "_on_chance_changed")
	
	assert_is(requisite_node_instance.get_child(4), Label, "Fourth child should be Label")
	assert_eq(requisite_node_instance.get_child(4).text, "Minimum Turn")
	
	assert_is(requisite_node_instance.get_child(5), LineEdit, "Fifth child should be LineEdit")
	assert_eq(requisite_node_instance.get_child(5).text, "5", "Min Turn value not assigned in LineEdit")
	assert_connected(requisite_node_instance.get_child(5), requisite_node_instance, "text_changed")
	
	assert_is(requisite_node_instance.get_child(6), Label, "Sixth child should be Label")
	assert_eq(requisite_node_instance.get_child(6).text, "Maximum Turn")
	
	assert_is(requisite_node_instance.get_child(7), LineEdit, "Seventh child should be LineEdit")
	assert_eq(requisite_node_instance.get_child(7).text, "-1", "Max Turn value not assigned in LineEdit")
	assert_connected(requisite_node_instance.get_child(7), requisite_node_instance, "text_changed")
	
	assert_is(requisite_node_instance.get_child(8), Label, "Eighth child should be Label")
	assert_eq(requisite_node_instance.get_child(8).text, "Output")


func test_ports():
	assert_eq(requisite_node_instance.get_input_port_count(), 1)
	assert_true(requisite_node_instance.is_slot_enabled_left(1))
	assert_eq(requisite_node_instance.get_slot_type_left(0), RequisiteGraphNode.InPortNums.TASK)
	assert_eq(requisite_node_instance.get_output_port_count(), 1)
	assert_true(requisite_node_instance.is_slot_enabled_right(8))
	assert_eq(requisite_node_instance.get_slot_type_right(0), RequisiteGraphNode.OutPortNums.MESSAGE)


func test_on_requisite_chance_changed():
	requisite_node_instance._on_chance_changed(0.7)
	assert_eq(requisite_node_instance.prerequisite.chance, 0.7)


func test_on_requisite_min_turn_changed():
	var min_turn_line_edit : LineEdit = requisite_node_instance.get_child(5) 
	requisite_node_instance._on_min_turn_changed("5", min_turn_line_edit)
	assert_eq(requisite_node_instance.prerequisite.min_turn, 5)
	assert_eq(min_turn_line_edit.self_modulate, Color.WHITE) 
	requisite_node_instance._on_min_turn_changed("text", min_turn_line_edit)
	assert_eq(requisite_node_instance.prerequisite.min_turn, 0)
	assert_eq(min_turn_line_edit.self_modulate, Color.RED)


func test_on_requisite_max_turn_changed():
	var max_turn_line_edit : LineEdit = requisite_node_instance.get_child(7) 
	requisite_node_instance._on_max_turn_changed("5", max_turn_line_edit)
	assert_eq(requisite_node_instance.prerequisite.max_turn, 5)
	assert_eq(max_turn_line_edit.self_modulate, Color.WHITE) 
	requisite_node_instance._on_max_turn_changed("text", max_turn_line_edit)
	assert_eq(requisite_node_instance.prerequisite.max_turn, -1)
	assert_eq(max_turn_line_edit.self_modulate, Color.RED)


func test_create_node_to_connect_to_empty():
	var connected_node = requisite_node_instance.create_node_to_connect_to_empty(RequisiteGraphNode.OutPortNums.MESSAGE)
	assert_is(connected_node, MessageGraphNode)
	connected_node.free()
	assert_eq(requisite_node_instance.create_node_to_connect_to_empty(100), null)


func test_create_node_to_connect_from_empty():
	var connected_node = requisite_node_instance.create_node_to_connect_from_empty(RequisiteGraphNode.InPortNums.TASK)
	assert_is(connected_node, TaskGraphNode)
	connected_node.free()
	assert_eq(requisite_node_instance.create_node_to_connect_from_empty(100), null)


func test_assign_connection():
	var task_node = TaskGraphNode.new(TaskData.new("Test"))
	assert_true(requisite_node_instance.assign_connection(RequisiteGraphNode.InPortNums.TASK, task_node))
	assert_eq(len(requisite_node_instance.prerequisite.task_id), 1)
	task_node.free()
	assert_false(requisite_node_instance.assign_connection(0, null))


func test_remove_connection():
	var task_node = TaskGraphNode.new(TaskData.new("Test"))
	requisite_node_instance.assign_connection(RequisiteGraphNode.InPortNums.TASK, task_node)
	assert_true(requisite_node_instance.remove_connection(RequisiteGraphNode.InPortNums.TASK, task_node))
	assert_eq(len(requisite_node_instance.prerequisite.task_id), 0)
	task_node.free()
	assert_false(requisite_node_instance.remove_connection(0, null))
