extends GutTest

var message_page_instance : MessagePage
var message_layout : VBoxContainer

func before_each():
	message_page_instance = load("res://Scenes/UI/message_page.tscn").instantiate()
	message_layout = message_page_instance.get_node("%MessagesLayout")
	add_child_autofree(message_page_instance)


func test_back_button_connected():
	var back_button = message_page_instance.get_node("%BackButton")
	assert_connected(back_button, message_page_instance, "pressed")


func test_null_message_set():
	var response_button = message_page_instance.get_node("%RespondButton")
	message_page_instance.show_message(null)
	assert_eq(message_layout.get_child_count(), 0)
	assert_not_connected(response_button, message_page_instance, "pressed")


func test_message_set_no_player_response():
	var message_instance : MessageInstance = MessageInstance.new()
	var message : Message = message_instance.message
	var response_button = message_page_instance.get_node("%RespondButton")
	message_page_instance.show_message(message_instance)
	assert_eq(message_layout.get_child_count(), 2) #Includes spacer
	assert_connected(response_button, message_page_instance, "pressed")


func test_message_set_player_response():
	var message_instance : MessageInstance = MessageInstance.new()
	var message : Message = message_instance.message
	var response_button = message_page_instance.get_node("%RespondButton")
	message_instance.reply(Response.new("", "Text"))
	message_page_instance.show_message(message_instance)
	assert_eq(message_layout.get_child_count(), 3) #Includes spacer
	assert_connected(response_button, message_page_instance, "pressed")


func test_null_after_message_set():
	var message_instance : MessageInstance = MessageInstance.new()
	var message : Message = message_instance.message
	var response_button = message_page_instance.get_node("%RespondButton")
	message_instance.reply(Response.new("", "Text"))
	message_page_instance.show_message(message_instance)
	message_page_instance.show_message(null)
	assert_eq(message_layout.get_child_count(), 0)
	assert_not_connected(response_button, message_page_instance, "pressed")


func test_set_contact_info():
	var sender_image = load("res://Sprites/icon.svg")
	var sender : Sender = Sender.new("Name", sender_image, 40)
	message_page_instance._set_contact_info(sender)
	var contact_profile = message_page_instance.get_node("%ContactProfile")
	var name_label = message_page_instance.get_node("%ContactNameLabel")
	var relation_bar = message_page_instance.get_node("%ContactRelationBar")
	var relation_label = message_page_instance.get_node("%ContactRelationLabel")
	assert_eq(contact_profile.texture, sender_image)
	assert_eq(name_label.text, sender.name)
	assert_eq(relation_bar.self_modulate, sender.get_relationship_color())
	assert_eq(relation_bar.value, sender.relationship)
	assert_eq(relation_bar.max_value, 100.0)
	assert_eq(relation_bar.min_value, -100.0)
	assert_eq(relation_label.text, sender.get_relationship_status())
