extends Control

enum UIPageState {
	CLOSED,
	TASK_DETAILS,
	RESOURCES,
	MESSAGES
}

var current_ui_page_state : UIPageState = UIPageState.CLOSED

func _ready() -> void:
	UIEvent.navbar_resource_button_pressed.connect(_navbar_resource_button_pressed)
	UIEvent.navbar_message_button_pressed.connect(_navbar_message_button_pressed)
	UIEvent.task_widget_view_details_pressed.connect(_task_widget_view_details_pressed)
	%ResourcesPage.return_button_pressed.connect(func(): _change_page_state(UIPageState.CLOSED))
	%ResourcesPage.return_button_pressed.connect(func(): UIEvent.resource_page_close.emit())
	%TaskDetailsPage.return_button_pressed.connect(func(): _change_page_state(UIPageState.CLOSED))


# Handle the navbar resource button press event
func _navbar_resource_button_pressed():
	if current_ui_page_state == UIPageState.CLOSED:
		_change_page_state(UIPageState.RESOURCES)
	elif current_ui_page_state == UIPageState.RESOURCES:
		_change_page_state(UIPageState.CLOSED)
	else:
		_change_page_state(UIPageState.RESOURCES)


# Handle the task widget view details button press event
func _task_widget_view_details_pressed(_task_instance : TaskInstance):
	if current_ui_page_state == UIPageState.CLOSED:
		_change_page_state(UIPageState.TASK_DETAILS)
	elif current_ui_page_state == UIPageState.TASK_DETAILS:
		_change_page_state(UIPageState.CLOSED)
	else:
		_change_page_state(UIPageState.TASK_DETAILS)


# Handle the navbar message button press event
func _navbar_message_button_pressed():
	if current_ui_page_state == UIPageState.CLOSED:
		_change_page_state(UIPageState.MESSAGES)
	elif current_ui_page_state == UIPageState.MESSAGES:
		_change_page_state(UIPageState.CLOSED)
	else:
		_change_page_state(UIPageState.MESSAGES)


# Change the UI page state and visibility
func _change_page_state(new_state : UIPageState):
	_change_page_visibility(current_ui_page_state, false)
	_change_page_visibility(new_state, true)
	current_ui_page_state = new_state


# Change the visibility of the respective UI page
func _change_page_visibility(page : UIPageState, visibility : bool):
	if page == UIPageState.TASK_DETAILS:
		%TaskDetailsPage.visible = visibility
	elif page == UIPageState.RESOURCES:
		if not visibility:
			UIEvent.resource_page_close.emit()
		if visibility:
			UIEvent.resource_page_open.emit()
		%ResourcesPage.visible = visibility
	elif page == UIPageState.MESSAGES:
		# If showing messages page, switch state to MESSAGE_RECEIVED
		if visibility:
			UIEvent.message_page_open.emit()
			%MessagePageController._change_page_state(\
			%MessagePageController.MessagePageState.MESSAGE_RECEIVED)
		else:
			UIEvent.message_page_close.emit()
			%MessagePageController._change_page_state(%MessagePageController.MessagePageState.CLOSED)
