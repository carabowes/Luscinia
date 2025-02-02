extends GutTest

var resources = {}
var available_resources = {}

func before_each():
	ResourceManager.resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
	ResourceManager.available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}	

func test_add_resources():
	ResourceManager.add_resources("funds", 500)
	assert_eq(ResourceManager.resources["funds"],1500,"funds should equal 1500")

func test_add_available_resources():
	ResourceManager.add_available_resources("funds", 500)
	assert_eq(ResourceManager.available_resources["funds"],1500,"funds should equal 1500")
	
