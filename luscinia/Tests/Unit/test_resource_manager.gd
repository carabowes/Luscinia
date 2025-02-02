extends GutTest

var resources = {}
var available_resources = {}

func before_each():
	resources = ResourceManager.resources.duplicate(true)  
	available_resources = ResourceManager.available_resources.duplicate(true)  

func test_add_resources():
	ResourceManager.add_resources("funds", 500)
	assert_eq(resources["funds"],1500,"funds should equal 1500")

func test_add_available_resources():
	ResourceManager.add_available_resources("funds", 500)
	assert_eq(available_resources["funds"],1500,"funds should equal 1500")
	
