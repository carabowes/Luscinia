extends Node

#Message signals
signal message_read(message : MessageInstance)
signal message_responded(response : Response, message : MessageInstance)
signal all_messages_read(message : Message)

#Task signals
signal task_started(task_instace : TaskInstance)
signal task_finished(task_instance : TaskInstance)
signal task_cancelled(task_instance : TaskInstance)

#General UI Signals
signal task_widget_view_details_pressed(task_instance : TaskInstance)
signal navbar_message_button_pressed
signal message_page_open
signal message_page_close
signal navbar_resource_button_pressed
signal resource_page_open
signal resource_page_close
