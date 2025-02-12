extends GutTest

var message_button

func before_each():
	message_button = Button.new()
	message_button.set_script( load("res://Scripts/UI/message_notification_button.gd"))
	add_child_autofree(message_button)


func test_visibility():
	assert_false(message_button.visible)


func test_show_on_message():
	MessageManager.message_sent.emit(null)
	assert_true(message_button.visible)


func test_hide_on_read():
	message_button.visible = true
	EventBus.all_messages_read.emit()
	assert_false(message_button.visible)


func assert_connections():
	assert_connected(message_button, message_button, "pressed")
