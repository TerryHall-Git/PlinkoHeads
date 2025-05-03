class_name Rocket extends AnimatableBody2D

@onready var rocketSfx: AudioStream = preload("res://sound/rocket.mp3") 

@export var speed: float = 800.0  # Speed of the rocket in pixels per second
@export var maxDistance: float = 1000.0  # Distance after which the rocket destroys itself
@export var moveRight: bool = true  # Determines the direction of the rocket (true = right, false = left)

@onready var audioPlayer:AudioStreamPlayer2D = $AudioStreamPlayer2D

var startPosition: Vector2  # The starting position of the rocket

func _ready() -> void:
	# Store the starting position
	startPosition = global_position
	audioPlayer.stream = rocketSfx
	audioPlayer.play()

func _physics_process(delta: float) -> void:
	# Move the rocket in the specified direction
	if moveRight:
		global_position.x += speed * delta  # Move right
	else:
		global_position.x -= speed * delta  # Move left

	# Check if the rocket has moved past the screen bounds
	var viewportWidth = get_viewport_rect().size.x
	var leftEdge = -viewportWidth 
	var rightEdge = viewportWidth * 2 

	if global_position.x > rightEdge or global_position.x < leftEdge:
		queue_free()  # Destroy the rocket

func _on_body_entered(body: Node) -> void:
	# Check if the colliding body has a physics body
	if body is PhysicsBody2D:
		# Calculate the deflection force
		var force = (global_position - body.global_position).normalized() * speed * 2.0
		# Apply the force to the body
		if body.has_method("apply_impulse"):
			body.apply_impulse(Vector2.ZERO, force)

	# Destroy the rocket after collision
	queue_free()
