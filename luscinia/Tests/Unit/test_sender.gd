extends GutTest

var sender: Sender


func before_each():
	sender = Sender.new("Test Sender",null,0)


func test_initialisation():
	assert_eq(sender.name, "Test Sender", "Sender name should be correctly set")
	assert_eq(sender.image, null, "Sender image should be null by default")
	assert_eq(sender.relationship, 0, "Relationship should start at neutral (0)")


func test_get_relationship_status():
	sender.relationship = 120
	assert_eq(sender.get_relationship_status(), "Outstanding", "Relationship >100 should be 'Outstanding'")

	sender.relationship = 80
	assert_eq(sender.get_relationship_status(), "Excellent", "Relationship >75 should be 'Excellent'")

	sender.relationship = 60
	assert_eq(sender.get_relationship_status(), "Good", "Relationship >50 should be 'Good'")

	sender.relationship = 20
	assert_eq(sender.get_relationship_status(), "Cooperative", "Relationship >15 should be 'Cooperative'")
	
	sender.relationship = 0
	assert_eq(sender.get_relationship_status(), "Neutral", "Relationship 0 should be 'Neutral'")

	sender.relationship = -30
	assert_eq(sender.get_relationship_status(), "Strained", "Relationship between -15 and -50 should be 'Strained'")

	sender.relationship = -60
	assert_eq(sender.get_relationship_status(), "Difficult", "Relationship between -50 and -75 should be 'Difficult'")

	sender.relationship = -100
	assert_eq(sender.get_relationship_status(), "Hostile", "Relationship below -75 should be 'Hostile'")


	
	
