extends RigidBody2D

@onready var bounceSfx: AudioStream = preload("res://sound/Bounce.mp3")  

@onready var sprite: Sprite2D = $mask 
@onready var audioPlayer: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var baseStretchFactor: float = 1.1  # Base stretch factor
@export var maxStretchFactor: float = 1.5  # Maximum stretch factor
@export var stretchDuration: float = 0.2  # Duration of the stretch effect
@export var collisionForceScale: float = 1000.0  # Scale to normalize collision force
@export var velocityThreshold: float = 50.0  # Minimum velocity to trigger stretching
@export var maxVelocity: float = 1500.0  # Maximum velocity for the ball
@export var soundForceThreshold: float = 200.0

@export var rotationReturnDuration: float = 0.1  # Duration to rotate back to 0
@export var bounceHeight: float = 25.0  # Height of the bounce effect
@export var bounceDuration: float = 0.5  # Duration of one bounce cycle

var disableReactions: bool = false
var isStretching: bool = false
var isCelebrating: bool = false
var originalScale: Vector2 = Vector2.ONE

func _ready():
	Global.player = get_tree().current_scene.find_child("PlinkoBall")
	originalScale = sprite.scale
		
func _physics_process(_delta: float) -> void:
	if disableReactions: return
		
	# Clamp the velocity to the maximum velocity
	if linear_velocity.length() > maxVelocity:
		linear_velocity = linear_velocity.normalized() * maxVelocity
		
	# Keep rotation at zero during the bounce effect
	if isCelebrating:
		rotation = 0
		
	# Check if the ball has stopped moving
	if linear_velocity.length() < velocityThreshold and !isCelebrating and global_position.y > Global.maxLevelSizeY:
		# Start the rotation tween back to 0
		tweenRotateToZero()
		# Start the bounce effect
		startBounceEffect()

func tweenRotateToZero():
	# Use a Tween to rotate the ball back to 0
	var tween = create_tween()
	tween.tween_property(self, "rotation", 0, rotationReturnDuration)

func startBounceEffect():
	isCelebrating = true
	var tween = create_tween()
	# Bounce the ball up and down repeatedly
	tween.tween_property(sprite, "position:y", sprite.position.y - bounceHeight, bounceDuration / 2)
	tween.tween_property(sprite, "position:y", sprite.position.y, bounceDuration / 2)
	tween.set_loops(3)  
	tween.finished.connect(func():
		isCelebrating = false)
		
func _on_body_entered(body: Node):
	if disableReactions: return
	# Calculate the collision force
	var relativeVelocity = linear_velocity - body.linear_velocity if body is RigidBody2D else linear_velocity
	var collisionForce = relativeVelocity.length()

	# Only play the bounce sound if the collision force exceeds the threshold
	if collisionForce > soundForceThreshold:
		audioPlayer.pitch_scale = randf_range(0.9, 1.1)  # Randomize pitch between 0.9 and 1.1
		audioPlayer.stream = bounceSfx
		audioPlayer.play()
	
	
	if not isStretching:
		# Check if the velocity is above the threshold
		if linear_velocity.length() < velocityThreshold:
			return  
			
		isStretching = true

		# Normalize the collision force to a smaller range
		# Adjust collisionForceScale to control the sensitivity of the stretch
		var normalizedForce = collisionForce / collisionForceScale

		# Map the normalized force to a stretch factor
		var stretchFactor = baseStretchFactor + normalizedForce * (maxStretchFactor - baseStretchFactor)
		stretchFactor = clamp(stretchFactor, baseStretchFactor, maxStretchFactor)

		# Calculate the contact normal in local space
		var contactNormal = (global_position - body.global_position).normalized()
		var localContactNormal = contactNormal.rotated(-rotation)


		# Apply the stretch
		stretchBall(localContactNormal, stretchFactor)

func stretchBall(localContactNormal: Vector2, stretchFactor: float):
	var stretchX = originalScale.x
	var stretchY = originalScale.y

	# Determine stretch based on the contact normal
	if abs(localContactNormal.x) > abs(localContactNormal.y):
		# Horizontal collision (left or right)
		stretchX = originalScale.x * stretchFactor
		stretchY = originalScale.y / stretchFactor
	else:
		# Vertical collision (top or bottom)
		stretchY = originalScale.y * stretchFactor
		stretchX = originalScale.x / stretchFactor

	# Use a Tween to smoothly apply the stretch
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(stretchX, stretchY), stretchDuration / 2)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", originalScale, stretchDuration / 2)
	tween.set_ease(Tween.EASE_IN)
	
	# Reset the stretching flag after the tween finishes
	tween.finished.connect(onTweenFinished)

func onTweenFinished():
	isStretching = false
