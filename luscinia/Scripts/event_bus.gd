extends Node

#Message signals
signal message_responded(response : Response, message : MessageInstance)
signal all_messages_read(message : Message)

#Task signals
signal task_finished(task_instance : TaskInstance, cancelled : bool)
signal task_started(task_instace : TaskInstance)

#General UI Signals
signal task_widget_view_details_pressed(task_instance : TaskInstance)
signal navbar_message_button_pressed
signal navbar_resource_button_pressed
