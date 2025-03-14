extends GutTest

var navbar

func before_each():
	navbar = load("res://Scenes/navbar.tscn").instantiate()
	add_child(navbar)


func after_each():
	navbar.free()
	

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
	watch_signals(GameManager)
	navbar._view_resource_button_pressed()
	assert_signal_emitted(GameManager, "navbar_resource_button_pressed")
	

func test_message_button_emits_signal():
	watch_signals(GameManager)
	navbar._message_button_pressed()
	assert_signal_emitted(GameManager, "navbar_message_button_pressed", "Navbar Button pressed signal not emitted")


func test_message_notification_bubble():
	var bubble : Control = navbar.get_node("%NewMessageNotif")
	assert_false(bubble.visible, "Notif bubble should be hidden initally")
	GameManager.message_sent.emit(null)
	assert_true(bubble.visible, "Bubble should appear on a message sent")
	GameManager.all_messages_read.emit()
	await wait_seconds(0.5)
	assert_false(bubble.visible, "Bubble should dissappear when all messages are read")


func test_skip_time_button_increments_turn():
	var timer : GameTimer = GameTimer.new(5, 0, 60, 0, 0)
	var initial_turn_count = timer.current_turn
	navbar.game_timer = timer
	navbar._skip_time_button_pressed()
	assert_eq(timer.current_turn, initial_turn_count + 1, "Turn count should increment when skipping time")
