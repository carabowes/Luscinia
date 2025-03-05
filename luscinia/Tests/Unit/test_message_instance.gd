extends GutTest

var read_params = ParameterFactory.named_parameters(
	['start_state', 'expected_state'], 
	[
		[MessageInstance.MessageStatus.UNREAD, MessageInstance.MessageStatus.READ],
		[MessageInstance.MessageStatus.READ, MessageInstance.MessageStatus.READ],
		[MessageInstance.MessageStatus.REPLIED, MessageInstance.MessageStatus.REPLIED],
	]
)

var turn_params = ParameterFactory.named_parameters(
	['turns', 'expected_turns'], 
	[
		[1, 1],
		[0, -1],
		[-1, -1],
	]
)

func test_init():
	var message_instance : MessageInstance = MessageInstance.new()
	assert_not_null(message_instance)
	assert_eq(message_instance.message_status, MessageInstance.MessageStatus.UNREAD)


func test_read_message(params = use_parameters(read_params)):
	var message_instance : MessageInstance = MessageInstance.new()
	message_instance.message_status = params.start_state
	message_instance.read()
	assert_eq(message_instance.message_status, params.expected_state)


func test_reply_message():
	var message_instance : MessageInstance = MessageInstance.new()
	assert_eq(message_instance.player_response, "")
	assert_ne(message_instance.message_status, MessageInstance.MessageStatus.REPLIED)
	message_instance.reply(Response.new("Response", "test"))
	assert_eq(message_instance.player_response, "test")
	assert_eq(message_instance.message_status, MessageInstance.MessageStatus.REPLIED)


func test_turns_assignment(params = use_parameters(turn_params)):
	var message : Message = Message.default_message
	message.turns_to_answer = params.turns
	var message_instance : MessageInstance = MessageInstance.new(message)
	assert_eq(message_instance.turns_remaining, params.expected_turns)
