extends GutTest

var navbar
var resource_page
var message_history

func before_each():
	navbar = load("res://Scenes/navbar.tscn").instantiate()
	add_child(navbar)
	resource_page = Control.new()
	resource_page.visible = false
	
	message_history = Control.new()
	message_history.visible = false
	navbar.message_history = message_history
	
	
func after_each():
	navbar.free()
	resource_page.free()
	message_history.free()
	

func test_button_signals():
	var _view_resources_button = navbar.get_node("%ViewResourcesButton")
	var _skip_time_button = navbar.get_node("%SkipTimeButton")
	var _view_message_history_button = navbar.get_node("%ViewMessageHistoryButton")

	assert_not_null(_view_resources_button, "ViewResourcesButton should exist")
	assert_not_null(_skip_time_button, "SkipTimeButton should exist")
	assert_not_null(_view_message_history_button, "ViewMessageHistoryButton should exist")

	assert_true(_view_resources_button.is_connected("pressed", Callable(navbar, "_view_resource_button_pressed")), "ViewResourcesButton should be connected to pressed signal")
	assert_true(_skip_time_button.is_connected("pressed", Callable(navbar, "_skip_time_button_pressed")), "SkipTimeButton should be connected to pressed signal")
	assert_true(_view_message_history_button.is_connected("pressed", Callable(navbar, "_message_button_pressed")), "ViewMessageHistoryButton should be connected to pressed signal")


func test_view_resources_button_signal_emits_correctly():
	var button = navbar.get_node("%ViewResourcesButton")
	assert_not_null(button, "ViewResourcesButton should exist")
	button.emit_signal("pressed")
	
	
func test_view_resource_toggle():
	watch_signals(EventBus)
	navbar._view_resource_button_pressed()
	assert_signal_emitted(EventBus, "navbar_resource_button_pressed")
	

func test_message_toggle():
	assert_false(message_history.visible, "Initial state should be hidden")
	navbar._message_button_pressed()
	assert_true(message_history.visible, "Message history should be visible after clicking button")
	navbar._message_button_pressed()
	assert_false(message_history.visible, "Message history should toggle back to hidden")
	

func test_skip_time_button_increments_turn():
	var initial_turn_count = GlobalTimer.turns
	navbar._skip_time_button_pressed()
	assert_eq(GlobalTimer.turns, initial_turn_count + 1, "Turn count should increment when skipping time")
