extends Node2D

@export var speed: float = 200.0  # Movement speed in pixels per second
@export var lerpSpeed: float = 100.0  # Speed of the lerp interpolation
var leftLimit: float = 0.0  # Left boundary for movement
var rightLimit: float = 0.0  # Right boundary for movement
var direction = 0

@onready var animPlayer: AnimationPlayer = $AnimationPlayer

func _ready():
	# Get the main camera
	var camera = get_viewport().get_camera_2d()
	if camera:
		# Get the width of the collision shape
		var collisionShape = $CollisionShape2D
		var shapeWidth = 0.0
		if collisionShape and collisionShape.shape is RectangleShape2D:
			shapeWidth = collisionShape.shape.extents.x * 2  # Full width of the shape

		# Calculate the limits based on the camera's boundaries
		leftLimit = camera.position.x - camera.zoom.x * get_viewport_rect().size.x / 2 + shapeWidth / 2
		rightLimit = camera.position.x + camera.zoom.x * get_viewport_rect().size.x / 2 - shapeWidth / 2

func updateAnimation():
	if direction < 0:
		if animPlayer.current_animation != "move_left":
			animPlayer.play("move_left")
	elif direction > 0:
		if animPlayer.current_animation != "move_right":
			animPlayer.play("move_right")
	else:
		if animPlayer.current_animation != "idle":
			animPlayer.play("idle")

func _process(delta: float) -> void:
	# Get input for left and right movement
	direction = 0
	if Input.is_action_pressed("ui_left") && Global.canPlay:
		direction -= 1
	if Input.is_action_pressed("ui_right") && Global.canPlay:
		direction += 1

	updateAnimation()
	
	# Calculate the new position
	var targetPosition = position.x + direction * speed * delta

	# Clamp the position within the specified limits
	targetPosition = clamp(targetPosition, leftLimit, rightLimit)

	# Smoothly interpolate toward the target position
	position.x = lerp(position.x, targetPosition, lerpSpeed * delta)
