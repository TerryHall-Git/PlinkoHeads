extends AnimatableBody2D

@export var points: Array[Vector2] = [Vector2(0, 0), Vector2(200, 0), Vector2(200, 200)]  # Array of points to move between
@export var moveSpeed: float = 100.0  # Movement speed in pixels per second
@export var bobbingAmplitude: float = 3.0  # Amplitude of the bobbing (Y-axis)
@export var bobbingFrequency: float = 1.0  # Frequency of the bobbing (cycles per second)
@export var enableBobbing: bool = true  # Toggle for bobbing effect

@onready var animPlayer: AnimationPlayer = $AnimationPlayer

var currentIndex: int = 0  # Current index in the points array
var movingForward: bool = true  # True if moving forward, false if moving backward
var bobbingTime: float = 0.0  # Tracks time for the bobbing effect

func _ready() -> void:
	animPlayer.play("moving_left")
	# Initialize the position to the starting point
	if points.size() > 0:
		global_position = points[0]

func _physics_process(delta: float) -> void:
	if points.size() < 2:
		return  # No movement if there are fewer than 2 points

	while true:
		# Determine the target point
		var targetIndex = currentIndex + (1 if movingForward else -1)
		var targetPoint = points[targetIndex]

		# Calculate the direction to the target point
		var direction = (targetPoint - global_position).normalized()

		# Move toward the target point
		var newPosition = global_position + direction * moveSpeed * delta

		# Check if the target point is reached
		if newPosition.distance_to(targetPoint) <= moveSpeed * delta:
			# Snap to the target point
			newPosition = targetPoint
			currentIndex = targetIndex

			# Check if we need to reverse direction
			if currentIndex == points.size() - 1:
				movingForward = false  # Reverse direction at the end
				if animPlayer.current_animation != "moving_right":
					animPlayer.play("moving_right")
			elif currentIndex == 0:
				movingForward = true  # Reverse direction at the start
				if animPlayer.current_animation != "moving_left":
					animPlayer.play("moving_left")

			# Continue to the next target point
			delta -= newPosition.distance_to(global_position) / moveSpeed
			global_position = newPosition
		else:
			# Apply bobbing effect if enabled
			if enableBobbing:
				bobbingTime += delta
				var bobbingOffset = sin(2.0 * PI * bobbingFrequency * bobbingTime) * bobbingAmplitude
				newPosition.y += bobbingOffset

			# Update the global position and exit the loop
			global_position = newPosition
			break
