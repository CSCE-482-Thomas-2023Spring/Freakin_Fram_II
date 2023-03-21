extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set collision to fit the rectangle
	var rect = $ColorRect.get_rect()
	var center = rect.get_center()
	
	# Set CollisionShape Transform to the center
	$CollisionShape2D.position = center
	
	# Create a RectangleShape2D
	var collision_rect = RectangleShape2D.new()
	collision_rect.extents = Vector2(rect.size.x / 2, rect.size.y / 2)
	$CollisionShape2D.shape = collision_rect

