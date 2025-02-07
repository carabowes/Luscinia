extends Node

#Message page signals
signal navbar_message_button_pressed
signal message_selected(message : MessageInstance)
signal message_respond_button_pressed(message : Message)
signal response_option_selected(response : Response, message : Message)
signal message_received_page_back_button_pressed()
signal message_viewer_page_back_button_pressed()
signal message_response_page_back_button_pressed()
