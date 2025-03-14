extends GutTest

var received_page_prefab = load("res://Scenes/UI/message_received_page.tscn")
var sender : GutInputSender
var page_instance : MessageReceivedPage

func before_each():
	page_instance = received_page_prefab.instantiate()
	add_child_autofree(page_instance)


func after_each():
	if sender != null:
		sender.release_all()
		sender.clear()


func test_on_message_received():
	assert_eq(page_instance.get_node("%MessagesReceived").get_child_count(), 2) #Seperator and no messages label
	assert_true(page_instance.get_node("%NoMessagesLabel").visible)
	page_instance._on_message_received(MessageInstance.new())
	assert_null(page_instance.get_node_or_null("%NoMessagesLabel")) #Make sure no messages label is gone
	assert_eq(page_instance.get_node("%MessagesReceived").get_child_count(), 2) #2 because seperator is there
	page_instance._on_message_received(MessageInstance.new())
	assert_eq(page_instance.get_node("%MessagesReceived").get_child_count(), 4) #4 because seperator is added
	assert_eq(page_instance.num_messages, 2)


func test_new_message_at_top():
	page_instance._on_message_received(MessageInstance.new())
	var top = page_instance.get_node("%MessagesReceived").get_child(0)
	page_instance._on_message_received(MessageInstance.new())
	assert_ne(top, page_instance.get_node("%MessagesReceived").get_child(0), "New messages should be at the top of the received messages.")


func test_back_button():
	watch_signals(GameManager)
	var back_button : Button = page_instance.get_node("%BackButton")
	back_button.pressed.emit()
	assert_signal_emitted(GameManager, "navbar_message_button_pressed")


func test_message_selected():
	watch_signals(page_instance)
	var message_instance = MessageInstance.new()
	page_instance._on_message_received(message_instance)
	var message_node = page_instance.get_node("%MessagesReceived").get_child(0)
	sender = InputSender.new(message_node)
	sender.action_down("interact")
	assert_signal_emitted_with_parameters(page_instance, "message_selected", [message_instance])


func test_message_sent_connection():
	GameManager.message_sent.emit(MessageInstance.new())
	assert_eq(page_instance.get_node("%MessagesReceived").get_child_count(), 2) #2 because seperator is there
