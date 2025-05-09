extends Node2D

@export var maxExtend: float = 228
@export var extendDuration: float = 0.1  # Duration for extending in seconds
@export var retractDuration: float = 0.5  # Duration for retracting in seconds
@export var rotationSpeed: float = 90.0  # Rotation speed in degrees per second
@export var reverseRotation: bool = false  # Option to reverse rotation
@export var minStartDelay: float = 0.0  # Minimum random delay in seconds
@export var maxStartDelay: float = 2.0  # Maximum random delay in seconds

@onready var topPart: StaticBody2D = $top
@onready var bottomPart: StaticBody2D = $bottom
@onready var audioPlayer: AudioStreamPlayer2D = $AudioStreamPlayer2D

var topOriginalPosition: Vector2
var bottomOriginalPosition: Vector2
var timeElapsed: float = 0.0
var extending: bool = true  # True when extending, false when retracting
var isActive: bool = false  # Controls whether the extend and rotate logic is active

func _ready() -> void:
	# Store the original positions of the top and bottom parts
	topOriginalPosition = topPart.position
	bottomOriginalPosition = bottomPart.position
	
	# Set a random initial rotation
	rotation = randf() * TAU  # TAU is equivalent to 2 * PI (full rotation in radians)

	# Start the extend and rotate logic after a random delay
	var startDelay = randf_range(minStartDelay, maxStartDelay)
	var timer = Timer.new()
	timer.wait_time = startDelay
	timer.one_shot = true
	timer.timeout.connect(_on_start_timer_timeout)
	add_child(timer)
	timer.start()

func _on_start_timer_timeout() -> void:
	# Activate the extend and rotate logic
	isActive = true

func _physics_process(delta: float) -> void:
	if isActive:
		_extendAndRotate(delta)

func _extendAndRotate(delta: float) -> void:
	# Update the elapsed time
	timeElapsed += delta

	# Determine the current duration based on whether extending or retracting
	var currentDuration = extendDuration if extending else retractDuration

	# Calculate the lerp factor (0 to 1 for extending, 1 to 0 for retracting)
	var lerpFactor = timeElapsed / currentDuration
	if not extending:
		lerpFactor = 1.0 - lerpFactor

	# Clamp the lerp factor to ensure it stays between 0 and 1
	lerpFactor = clamp(lerpFactor, 0.0, 1.0)

	# Calculate the new positions using lerp
	topPart.position = topOriginalPosition.lerp(topOriginalPosition + Vector2(0, -maxExtend), lerpFactor)
	bottomPart.position = bottomOriginalPosition.lerp(bottomOriginalPosition + Vector2(0, maxExtend), lerpFactor)

	# Check if the cycle is complete
	if timeElapsed >= currentDuration:
		timeElapsed = 0.0  # Reset the elapsed time
		extending = not extending  # Switch between extending and retracting
		if extending:
			audioPlayer.play()

	# Rotate self continuously, reverse direction if reverseRotation is true
	var rotationDirection = -1 if reverseRotation else 1
	rotation += deg_to_rad(rotationSpeed * delta * rotationDirection)

func deg_to_rad(degrees: float) -> float:
	return degrees * PI / 180.0
