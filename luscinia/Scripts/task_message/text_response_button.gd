class_name ResponseButton
extends Button

signal response_chosen (task_data : TaskData)

func initialise_button(task_data : TaskData):
	pressed.connect(func(): response_chosen.emit(task_data))
