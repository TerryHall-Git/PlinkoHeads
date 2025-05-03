extends StaticBody2D

@onready var handArea: Area2D = $handArea
@onready var base: Node2D = $Base
@onready var audioPlayer:AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var rotationSpeed: float = 90.0
@export var maxRotationSpeed: float = 540.0  
@export var speedIncreaseRate: float = 75.0
@export var holdCooldown: float = 3.0  
@export var releaseForceMultiplier: float = 10.0 

var isChasing: bool = false
var isHolding: bool = false
var targetExitedChaseZone: bool = true  
var cooldownActive: bool = false  
var cooldownTimer: Timer
var defaultGravity: float

func _ready() -> void:
	cooldownTimer = Timer.new()
	add_child(cooldownTimer)
	cooldownTimer.timeout.connect(_on_cooldown_timer_timeout)
	cooldownTimer.wait_time = holdCooldown
	cooldownTimer.one_shot = true
	defaultGravity = Global.player.gravity_scale

func _physics_process(delta: float) -> void:
	if isHolding:
		Global.player.global_position = handArea.global_position
		rotationSpeed += speedIncreaseRate * delta

		# Clamp the rotation speed to the maximum value
		rotationSpeed = min(rotationSpeed, maxRotationSpeed)

		if Input.is_action_just_pressed("ui_accept"):
			call_deferred("_releasePlayer")
	
	rotation -= deg_to_rad(rotationSpeed * delta)
	base.rotation = -rotation

func _holdPlayer() -> void:
	isHolding = true
	Global.player.freeze = true
	Global.player.lock_rotation = true
	Global.player.disableReactions = true
	Global.player.linear_velocity = Vector2.ZERO
	# Place the target at the marker's global position
	Global.player.global_position = handArea.global_position

func _releasePlayer() -> void:
	# Unlock the player and reset holding state
	Global.player.disableReactions = false
	Global.player.lock_rotation = false
	isHolding = false
	Global.player.freeze = false
	rotationSpeed = 60.0  # Reset rotation speed after release
	cooldownActive = true
	cooldownTimer.start()
	
	call_deferred("_apply_release_impulse") 

func _apply_release_impulse() -> void:
	# Calculate the vector from the RobotArm to the player
	var direction_to_player = (Global.player.global_position - global_position).normalized()

	# Calculate the force based on the current rotation speed
	var releaseForce = rotationSpeed * releaseForceMultiplier

	# Debugging: Print the calculated direction and force
	print("Direction to Player:", direction_to_player)
	print("Release Force:", releaseForce)

	# Apply force to the player in the calculated direction
	Global.player.apply_impulse(Vector2.ZERO, direction_to_player * releaseForce)
	
func deg_to_rad(degrees: float) -> float:
	return degrees * PI / 180.0

func _on_chase_area_body_entered(body: Node2D) -> void:
	if isHolding: return
	if body == Global.player and targetExitedChaseZone and not cooldownActive:
		isChasing = true
		targetExitedChaseZone = false  # Reset the flag since the target is now in the chase zone

func _on_chase_area_body_exited(body: Node2D) -> void:
	if isHolding: return
	if body == Global.player:
		isChasing = false
		targetExitedChaseZone = true  # Set the flag to allow holding again after the target exits

func _on_hand_area_body_entered(body: Node2D) -> void:
	if isHolding: return
	if body == Global.player and not targetExitedChaseZone and not cooldownActive:
		call_deferred("_holdPlayer")

func _on_cooldown_timer_timeout() -> void:
	cooldownActive = false
