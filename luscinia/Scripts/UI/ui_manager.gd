extends Control


func _ready() -> void:
	%Timer.game_timer = GameManager.get_timer()
	%Timer.resource_manager = GameManager.get_resource_manager()
	%MessagePageController.game_timer = GameManager.get_timer()
	%MessagePageController.resource_manager = GameManager.get_resource_manager()
	%TaskDetailsPage.game_timer = GameManager.get_timer()
	%TaskDetailsPage.resource_manager = GameManager.get_resource_manager()
	%TaskDetailsPage.task_manager = GameManager.get_task_manager()
	%Navbar.game_timer = GameManager.get_timer()
	%ResourcesPage.resource_manager = GameManager.get_resource_manager()
	%EndingScreen.resource_manager = GameManager.get_resource_manager()
