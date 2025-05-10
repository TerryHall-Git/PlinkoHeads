extends Node2D

@export var obstacles: Array[Node2D]

func _ready() -> void:
	# Ensure the random number generator is seeded
	randomize()
	
	# Shuffle the global positions of the obstacles
	var positions = []
	
	# Collect all global positions
	for obstacle in obstacles:
		positions.append(obstacle.global_position)
	
	# Shuffle the positions array
	positions.shuffle()
	
	# Assign the shuffled positions back to the obstacles
	for i in range(obstacles.size()):
		obstacles[i].global_position = positions[i]
