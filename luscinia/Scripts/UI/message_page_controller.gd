extends Control

# Enum to track the current state of the message page
enum MessagePageState {
	CLOSED,             # The page is closed
	MESSAGE_RECEIVED,   # A message has been received and is displayed
	MESSAGE_VIEWER,     # The message is being viewed
	MESSAGE_RESPONSE    # The user is responding to the message
}

# Variable to hold the current state of the message page
var current_message_page_state : MessagePageState = MessagePageState.CLOSED
# Variable to store the message instance when in the response page
var response_page_message : MessageInstance


# Called when the scene is loaded and ready
func _ready() -> void:
	# Connect the message selection event to change the page state to MESSAGE_VIEWER
	%MessagesReceivedPage.message_selected.connect(
		func(message : MessageInstance):
			_change_page_state(MessagePageState.MESSAGE_VIEWER)  # Change state to message viewer
			%MessagePage.show_message(message)  # Show the selected message in the message page
	)

	# Connect the respond button press event to change the page state to MESSAGE_RESPONSE
	%MessagePage.respond_button_pressed.connect(
		func(message_instance : MessageInstance):
			_change_page_state(MessagePageState.MESSAGE_RESPONSE)  # Change state to message response
			%MessageResponsePage.set_message(message_instance)  # Set the message on the response page
			response_page_message = message_instance  # Store the message instance to track the response
	)

	# Connect the back button press on the MessagePage to go back to the MESSAGE_RECEIVED state
	%MessagePage.back_button_pressed.connect(\
	func(): _change_page_state(MessagePageState.MESSAGE_RECEIVED))

	# Connect the event when a message is responded to update the UI accordingly
	EventBus.message_responded.connect(_on_message_responded)

	# Connect the response option selected on the MessageResponsePage to emit the response event
	%MessageResponsePage.response_option_selected.connect(
		func(response : Response, message_instance : MessageInstance):
			EventBus.navbar_message_button_pressed.emit()  # Trigger navbar message button event
			EventBus.message_responded.emit(response, message_instance)  # Emit the response
	)

	# Connect the back button on the MessageResponsePage to return to MESSAGE_VIEWER state
	%MessageResponsePage.back_button_pressed.connect(\
	func(): _change_page_state(MessagePageState.MESSAGE_VIEWER))


# Function to change the page state and handle visibility of different pages
func _change_page_state(new_state : MessagePageState):
	# Hide the current page based on the previous state
	_change_page_visibility(current_message_page_state, false)
	# Show the new page based on the new state
	_change_page_visibility(new_state, true)
	# Update the current state to the new state
	current_message_page_state = new_state


# Function to change the visibility of the pages based on the state
func _change_page_visibility(page : MessagePageState, visibility : bool):
	# Toggle visibility for the MESSAGE_RECEIVED page
	if page == MessagePageState.MESSAGE_RECEIVED:
		%MessagesReceivedPage.visible = visibility
	# Toggle visibility for the MESSAGE_VIEWER page
	elif page == MessagePageState.MESSAGE_VIEWER:
		%MessagePage.visible = visibility
	# Toggle visibility for the MESSAGE_RESPONSE page
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
		%MessagePage.show_message(message_instance)  # Show the message again after the response
		_change_page_state(MessagePageState.MESSAGE_VIEWER)  # Return to the MESSAGE_VIEWER state
