extends GutTest

var message_instance

func before_each():
	message_instance = Message.new()


func test_default_initialisation():
	assert_eq(message_instance.message, "", "Default message should be an empty string")
	assert_eq(message_instance.responses, [], "Default responses should be an empty list")
	assert_eq(message_instance.default_response, 0, "Default defaul response should be 0")
	assert_eq(message_instance.sender, Message.default_sender, "Default sender should be default sender")
	assert_eq(message_instance.prerequisites, [], "Default prerequisites should be an empty list")
	assert_eq(message_instance.antirequisites, [], "Default antirequisites should be an empty list")
	assert_eq(message_instance.turns_to_answer, 0, "Default turns to answer should be 0")
	assert_eq(message_instance.is_repeatable, false, "Default is_repeatable should be false")
	assert_eq(message_instance.cancel_behaviour, Message.CancelBehaviour.NOTHING, "Default cancel_behaviour should be NOTHING")


func test_custom_initialisation():
	var sender_instance = Sender.new()
	var response_instance = Response.new()
	var prerequisite_instance = Prerequisite.new()
	var antirequisite_instance = Prerequisite.new()
	var custom_message_instance = Message.new(
		"Test Message",
		[response_instance],
		2,
		sender_instance,
		[prerequisite_instance],
		[antirequisite_instance],
		3,
		true,
		Message.CancelBehaviour.FORCE_RESEND
	)
	
	assert_eq(custom_message_instance.message, "Test Message", "Message should be 'Test Message'")
	assert_eq(custom_message_instance.responses.size(), 1, "Responses should contain one Response instance")
	assert_eq(custom_message_instance.default_response, 2 , "Default response should be 2")
	assert_eq(custom_message_instance.sender, sender_instance, "Sender should be the assigned instance")
	assert_eq(custom_message_instance.prerequisites.size(), 1, "Prerequisites should contain one instance")
	assert_eq(custom_message_instance.antirequisites.size(), 1, "Antirequisites should contain one instance")
	assert_eq(custom_message_instance.turns_to_answer, 3, "Turns to answer should be 3")
	assert_eq(custom_message_instance.is_repeatable, true, "is_repeatable should be true")
	assert_eq(custom_message_instance.cancel_behaviour, Message.CancelBehaviour.FORCE_RESEND, "cancel_behaviour should be FORCE_RESEND")
