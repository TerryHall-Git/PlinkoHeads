extends Node2D

@export var rotationSpeed: float = 360.0  
@export var reverseRotation: bool = false  # Option to rotate in reverse

func _physics_process(delta: float) -> void:
	# Apply rotation, reversing if reverseRotation is true
	var speed = rotationSpeed if not reverseRotation else -rotationSpeed
	rotation += deg_to_rad(speed * delta)

func deg_to_rad(degrees: float) -> float:
	return degrees * PI / 180.0
