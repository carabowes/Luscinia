extends GutTest

var instance : ReceivedMessage

func before_each():
	instance = ReceivedMessage.new_instance(ReceivedMessage.default_message.duplicate())
	add_child_autofree(instance)


func test_new_instance():
	var message = MessageInstance.new()
	var test_instance = instance.new_instance(message)
	assert_not_null(test_instance)
	assert_eq(test_instance.message_info, message)
	test_instance.free()


func test_render_badge_side():
	instance.unread_badge_location = 0 #Side
	instance._render_badge_location()
	assert_eq(instance.get_node("%UnreadBadge").visible, true)
	assert_eq(instance.get_node("%ContactUnreadBadge").visible, false)


func test_render_badge_profile():
	instance.unread_badge_location = 1 #Side
	instance._render_badge_location()
	assert_eq(instance.get_node("%UnreadBadge").visible, false)
	assert_eq(instance.get_node("%ContactUnreadBadge").visible, true)


func test_unread_message_status():
	instance.message_info.message_status = MessageInstance.MessageStatus.UNREAD
	instance._render_message_status()
	assert_eq(instance.get_node("%UnreadBadge").self_modulate.a , 1.0)
	assert_eq(instance.get_node("%ContactUnreadBadge").self_modulate.a, 1.0)


func test_read_message_status():
	instance.message_info.message_status = MessageInstance.MessageStatus.READ
	instance._render_message_status()
	assert_eq(instance.get_node("%UnreadBadge").self_modulate.a , 0.0)
	assert_eq(instance.get_node("%ContactUnreadBadge").self_modulate.a, 0.0)


func test_replied_message_status():
	instance.message_info.message_status = MessageInstance.MessageStatus.REPLIED
	instance._render_message_status()
	assert_eq(instance.get_node("%UnreadBadge").self_modulate.a , 0.0)
	assert_eq(instance.get_node("%ContactUnreadBadge").self_modulate.a, 0.0)
	var test_color = Color.DIM_GRAY
	test_color.a = 0.5
	assert_eq(instance.get_node("%Layout").modulate,  test_color)
	assert_eq(instance.get_node("%TimeRemainingLabel").text, "REPLIED")


func test_render_info():
	instance.message_info.turns_remaining = 2
	instance.message_info.message_status = MessageInstance.MessageStatus.UNREAD
	var message = instance.message_info
	instance._render_message_info()
	assert_eq(instance.get_node("%MessagePreviewLabel").text, message.message.message)
	assert_eq(instance.get_node("%ContactNameLabel").text, message.message.sender.name)
	assert_eq(instance.get_node("%ContactImage").texture, message.message.sender.image)
	assert_eq(instance.get_node("%TimeRemainingLabel").self_modulate, instance.time_remaining_color)


func test_one_turn_left():
	instance.message_info.turns_remaining = 1
	instance.message_info.message_status = MessageInstance.MessageStatus.UNREAD
	instance._render_message_info()
	assert_eq(instance.get_node("%TimeRemainingLabel").text, "ANSWER NOW!")
	assert_eq(instance.get_node("%TimeRemainingLabel").self_modulate, instance.answer_now_color)


func test_two_turns_left():
	instance.message_info.turns_remaining = 2
	instance.message_info.message_status = MessageInstance.MessageStatus.UNREAD
	instance._render_message_info()
	assert_ne(instance.get_node("%TimeRemainingLabel").text, "ANSWER NOW!")
	assert_eq(instance.get_node("%TimeRemainingLabel").self_modulate, instance.time_remaining_color)


func test_no_turn_limit():
	instance.message_info.turns_remaining = -1
	instance._render_message_info()
	assert_eq(instance.get_node("%TimeRemainingLabel").self_modulate.a, 0.0)


func test_signal_emit_on_press():
	watch_signals(instance)
	var sender : GutInputSender = InputSender.new(instance)
	sender.mouse_left_button_down(instance.position + instance.size/2)
	assert_signal_emitted_with_parameters(instance, "message_clicked", [instance.message_info])
	sender.release_all()
	sender.clear()


func test_only_click_triggers_press():
	watch_signals(instance)
	var sender : GutInputSender = InputSender.new(instance)
	sender.mouse_set_position(instance.position + instance.size/2)
	sender.key_down(KEY_A)
	sender.action_down("scroll")
	assert_signal_not_emitted(instance, "message_clicked")
	sender.release_all()
	sender.clear()
