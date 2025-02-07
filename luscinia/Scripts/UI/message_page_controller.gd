extends Control

enum MessagePageState {
	CLOSED,
	MESSAGE_RECEIVED,
	MESSAGE_VIEWER,
	MESSAGE_RESPONSE
}

var current_message_page_state : MessagePageState = MessagePageState.CLOSED

func _ready() -> void:
	EventBus.navbar_message_button_pressed.connect(_navbar_button_pressed)
	EventBus.message_selected.connect(func(message): _change_page_state(MessagePageState.MESSAGE_VIEWER))
	EventBus.message_respond_button_pressed.connect(func(message): _change_page_state(MessagePageState.MESSAGE_RESPONSE))
	EventBus.response_option_selected.connect(func(response, message): _change_page_state(MessagePageState.CLOSED))
	EventBus.message_received_page_back_button_pressed.connect(func(): _change_page_state(MessagePageState.CLOSED))
	EventBus.message_viewer_page_back_button_pressed.connect(func(): _change_page_state(MessagePageState.MESSAGE_RECEIVED))
	EventBus.message_response_page_back_button_pressed.connect(func(): _change_page_state(MessagePageState.MESSAGE_VIEWER))


func _navbar_button_pressed():
	if current_message_page_state == MessagePageState.CLOSED:
		_change_page_state(MessagePageState.MESSAGE_RECEIVED)
	else:
		_change_page_state(MessagePageState.CLOSED)


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
