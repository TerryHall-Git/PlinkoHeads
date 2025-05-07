extends Camera2D

# Preload sounds
@onready var ding1: AudioStream = preload("res://sound/ding1.mp3")
@onready var ding2: AudioStream = preload("res://sound/ding2.mp3")

@export var target: RigidBody2D
@export var baseFollowSpeed: float = 5.0  # Base follow speed
@export var maxFollowSpeed: float = 20.0  # Maximum follow speed
@export var velocityThreshold: float = 500.0  # Velocity at which max follow speed is reached
@export var yOffset: float = 200.0 
@export var panDurationFrames: int = 360  # Duration of the initial pan in frames (e.g., 6 seconds at 60 FPS)

@onready var countLabel: RichTextLabel = $UI/CountLabel
@onready var menuSFX: AudioStreamPlayer = $MenuSFX

var isPanning: bool = true  # Flag to track if the camera is panning
var panStartFrame: int = 0  # Frame when the pan started
var currentFrame: int = 0  # Current frame count
var gameStarted: bool = false

func _ready():
	startGame()
	
func startGame():
	gameStarted = true
	# Start the camera at maxLevelSizeY
	position.y = Global.maxLevelSizeY
	
	# Record the start frame of the pan
	panStartFrame = 0
	currentFrame = 0
	updateUI()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", target.global_position.y + yOffset, float(panDurationFrames) / 60.0)
	tween.finished.connect(_on_pan_finished)

func _on_pan_finished():
	countLabel.visible = false
	isPanning = false  # Stop panning once the tween is complete

func updateUI():
	if !gameStarted: return
	var remainingFrames = max(0, panDurationFrames - currentFrame)
	var remainingTime = int(ceil(float(remainingFrames) / 60.0))-1  # Convert frames to seconds
	if remainingTime == 0:
		countLabel.text = "[center]START![/center]"
		menuSFX.stream = ding2
		menuSFX.play()
		Global.canPlay = true
	else:
		countLabel.text = "[center]" + str(remainingTime) + "[/center]"
		menuSFX.stream = ding1
		menuSFX.play()

func _process(delta):
	if isPanning:
		currentFrame += 1  # Increment the frame counter
		
		if currentFrame % 60 == 0 or currentFrame == panDurationFrames:
			updateUI()
		return  
		
	if target:
		var velocity = target.linear_velocity.length()
		var dynamicFollowSpeed = lerp(baseFollowSpeed, maxFollowSpeed, clamp(velocity / velocityThreshold, 0.0, 1.0))
		position.y = lerp(position.y, target.global_position.y + yOffset, dynamicFollowSpeed * delta)
		if position.y > Global.maxLevelSizeY: position.y = Global.maxLevelSizeY
