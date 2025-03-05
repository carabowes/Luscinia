extends Control

enum MessagePageState {
	CLOSED,
	MESSAGE_RECEIVED,
	MESSAGE_VIEWER,
	MESSAGE_RESPONSE
}

var current_message_page_state : MessagePageState = MessagePageState.CLOSED
var response_page_message : MessageInstance

func _ready() -> void:

	%MessagesReceivedPage.message_selected.connect(
		func(message : MessageInstance):
			_change_page_state(MessagePageState.MESSAGE_VIEWER)
			%MessagePage.show_message(message)
	)

	%MessagePage.respond_button_pressed.connect(
		func(message_instance : MessageInstance):
			_change_page_state(MessagePageState.MESSAGE_RESPONSE)
			%MessageResponsePage.set_message(message_instance)
			response_page_message = message_instance
	)
	EventBus.message_responded.connect(_on_message_responded)

	%MessageResponsePage.response_option_selected.connect(
		func(response : Response, message_instance : MessageInstance):
			EventBus.navbar_message_button_pressed.emit()
			EventBus.message_responded.emit(response, message_instance)
	)


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


func _on_message_responded(_response : Response, message_instance : MessageInstance):
	if (
		message_instance == response_page_message
		and current_message_page_state == MessagePageState.MESSAGE_RESPONSE
	):
		%MessagePage.show_message(message_instance)
		_change_page_state(MessagePageState.MESSAGE_VIEWER)
