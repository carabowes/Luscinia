extends GutTest

var received_page_prefab = load("res://Scenes/UI/message_received_page.tscn")

func test_receive_page_script_exists():
	var page : MessageReceivedPage = MessageReceivedPage.new()
	assert_not_null(page)


func test_receive_page_scene_exists():
	var instance = received_page_prefab.instantiate()
	assert_not_null(instance)


func test_on_message_received():
	var instance : MessageReceivedPage = received_page_prefab.instantiate()
	instance._on_message_received(MessageInstance.new())
	assert_eq(instance.get_node("%MessagesReceived").get_child_count(), 2) #2 because seperator is there
	instance._on_message_received(MessageInstance.new())
	assert_eq(instance.get_node("%MessagesReceived").get_child_count(), 4) #4 because seperator is added
