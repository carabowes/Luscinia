class_name ResponseButton
extends Button

signal response_chosen (task_data : TaskData, response_chosen : Response, sender : Sender)

func initialise_button(task_data : TaskData, response : Response, sender : Sender):
	pressed.connect(func(): response_chosen.emit(task_data, response, sender))
