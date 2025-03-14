extends Control

# Enum to track the current state of the message page
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

	# Connect the respond button press event to change the page state to MESSAGE_RESPONSE
	%MessagePage.respond_button_pressed.connect(
		func(message_instance : MessageInstance):
			_change_page_state(MessagePageState.MESSAGE_RESPONSE)
			%MessageResponsePage.set_message(message_instance)
			response_page_message = message_instance
	)

	# Connect the back button press on the MessagePage to go back to the MESSAGE_RECEIVED state
	%MessagePage.back_button_pressed.connect(\
	func(): _change_page_state(MessagePageState.MESSAGE_RECEIVED))

	EventBus.message_responded.connect(_on_message_responded)

	# Connect the response option selected on the MessageResponsePage to emit the response event
	%MessageResponsePage.response_option_selected.connect(
		func(response : Response, message_instance : MessageInstance):
			EventBus.navbar_message_button_pressed.emit()
			EventBus.message_responded.emit(response, message_instance)
	)

	# Connect the back button on the MessageResponsePage to return to MESSAGE_VIEWER state
	%MessageResponsePage.back_button_pressed.connect(\
	func(): _change_page_state(MessagePageState.MESSAGE_VIEWER))


# Function to change the page state and handle visibility of different pages
func _change_page_state(new_state : MessagePageState):
	_change_page_visibility(current_message_page_state, false)
	_change_page_visibility(new_state, true)
	current_message_page_state = new_state


# Function to change the visibility of the pages based on the state
func _change_page_visibility(page : MessagePageState, visibility : bool):
	if page == MessagePageState.MESSAGE_RECEIVED:
		%MessagesReceivedPage.visible = visibility
	elif page == MessagePageState.MESSAGE_VIEWER:
		%MessagePage.visible = visibility
	elif page == MessagePageState.MESSAGE_RESPONSE:
		%MessageResponsePage.visible = visibility


# Function to handle the event when a message has been responded to
func _on_message_responded(_response : Response, message_instance : MessageInstance):
	# Check if the message instance matches the one being viewed in the response page
	# and that the current state is MESSAGE_RESPONSE (responding to the message)
	if (
		message_instance == response_page_message
		and current_message_page_state == MessagePageState.MESSAGE_RESPONSE
	):
		%MessagePage.show_message(message_instance)
		_change_page_state(MessagePageState.MESSAGE_VIEWER)
