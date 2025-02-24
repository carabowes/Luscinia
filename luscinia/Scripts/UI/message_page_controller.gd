extends Control

enum MessagePageState {
	CLOSED,
	MESSAGE_RECEIVED,
	MESSAGE_VIEWER,
	MESSAGE_RESPONSE
}

var current_message_page_state : MessagePageState = MessagePageState.CLOSED

func _ready() -> void:
	EventBus.navbar_message_button_pressed.connect(_navbar_message_button_pressed)

	%MessagesReceivedPage.message_selected.connect(
		func(message : MessageInstance): 
			_change_page_state(MessagePageState.MESSAGE_VIEWER)
			%MessagePage.show_message(message)
	)
	%MessagesReceivedPage.back_button_pressed.connect(func(): _change_page_state(MessagePageState.CLOSED))

	%MessagePage.respond_button_pressed.connect(
		func(message): 
			_change_page_state(MessagePageState.MESSAGE_RESPONSE)
			%MessageResponsePage.set_message(message)
	)
	%MessagePage.back_button_pressed.connect(func(): _change_page_state(MessagePageState.MESSAGE_RECEIVED))

	%MessageResponsePage.response_option_selected.connect(
		func(response : Response, message : Message):
			_change_page_state(MessagePageState.CLOSED)
			EventBus.message_responded.emit(response, message)
	)
	%MessageResponsePage.back_button_pressed.connect(func(): _change_page_state(MessagePageState.MESSAGE_VIEWER))


func _navbar_message_button_pressed():
	#if current_message_page_state == MessagePageState.CLOSED:
		#_change_page_state(MessagePageState.MESSAGE_RECEIVED)
	#else:
		#_change_page_state(MessagePageState.CLOSED)
	#
	if current_message_page_state == MessagePageState.CLOSED:
		_change_page_state(MessagePageState.MESSAGE_RECEIVED)
	elif current_message_page_state == MessagePageState.MESSAGE_RECEIVED:
		_change_page_state(MessagePageState.CLOSED)
	else:
		_change_page_state(MessagePageState.MESSAGE_RECEIVED)


func _change_page_state(new_state : MessagePageState):
	_change_page_visibility(current_message_page_state, false)
	_change_page_visibility(new_state, true)
	current_message_page_state = new_state


func _change_page_visibility(page : MessagePageState, visibility : bool):
	if page == MessagePageState.MESSAGE_RECEIVED:
		%MessagesReceivedPage.visible = visibility
	elif page == MessagePageState.MESSAGE_VIEWER:
		%MessagePage.visible = visibility
	elif page == MessagePageState.MESSAGE_RESPONSE:
		%MessageResponsePage.visible = visibility
