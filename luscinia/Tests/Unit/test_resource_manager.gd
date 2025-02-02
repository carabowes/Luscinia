extends GutTest

var resources = {}
var available_resources = {}

func before_each():
	ResourceManager.resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
	ResourceManager.available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}	

func test_add_resources():
	ResourceManager.add_resources("funds", 500)
	assert_eq(ResourceManager.resources["funds"],1500,"funds should equal 1500")
	
func test_remove_resources():
	ResourceManager.remove_resources("funds", 500)
	assert_eq(ResourceManager.resources["funds"],500,"funds should equal 500")

func test_remove_resources_not_negative():
	ResourceManager.remove_resources("funds", 1100)
	assert_eq(ResourceManager.resources["funds"],0,"funds should equal 0, cannot be negative")
	
func test_add_available_resources():
	ResourceManager.add_available_resources("people", 500)
	assert_eq(ResourceManager.available_resources["people"],1500,"funds should equal 1500")

func test_remove_available_resources():
	ResourceManager.remove_available_resources("people", 500)
	assert_eq(ResourceManager.resources["people"],500,"funds should equal 500")

func test_get_resource_texture():
	var texture = ResourceManager.get_resource_texture("people")
	assert_eq(texture,preload("res://Sprites/UI/User.png"),"image texture should be User.png")
