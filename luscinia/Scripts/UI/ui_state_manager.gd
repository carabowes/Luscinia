extends Control

enum UIPageState {
	CLOSED,
	TASK_DETAILS,
	RESOURCES,
	MESSAGES
}

var current_ui_page_state : UIPageState = UIPageState.CLOSED

func _ready() -> void:
	# Connect signals to respective functions
	EventBus.navbar_resource_button_pressed.connect(_navbar_resource_button_pressed)
	EventBus.task_widget_view_details_pressed.connect(_task_widget_view_details_pressed)
	%ResourcesPage.return_button_pressed.connect(func(): _change_page_state(UIPageState.CLOSED))
	%ResourcesPage.return_button_pressed.connect(func(): EventBus.resource_page_close.emit())
	%TaskDetailsPage.return_button_pressed.connect(func(): _change_page_state(UIPageState.CLOSED))
	EventBus.navbar_message_button_pressed.connect(_navbar_message_button_pressed)


# Handle the navbar resource button press event
func _navbar_resource_button_pressed():
	if current_ui_page_state == UIPageState.CLOSED:
		EventBus.resource_page_open.emit()
		_change_page_state(UIPageState.RESOURCES)
	elif current_ui_page_state == UIPageState.RESOURCES:
		EventBus.resource_page_close.emit()
		_change_page_state(UIPageState.CLOSED)
	else:
		EventBus.resource_page_open.emit()
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
		EventBus.message_page_open.emit()
		_change_page_state(UIPageState.MESSAGES)
	elif current_ui_page_state == UIPageState.MESSAGES:
		EventBus.message_page_close.emit()
		_change_page_state(UIPageState.CLOSED)
	else:
		EventBus.message_page_open.emit()
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
		%ResourcesPage.visible = visibility
	elif page == UIPageState.MESSAGES:
		# If showing messages page, switch state to MESSAGE_RECEIVED
		if visibility:
			%MessagePageController._change_page_state(\
			%MessagePageController.MessagePageState.MESSAGE_RECEIVED)
		else:
			%MessagePageController._change_page_state(%MessagePageController.MessagePageState.CLOSED)
