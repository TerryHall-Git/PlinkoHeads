extends Camera2D

# Preload sounds
@onready var ding1: AudioStream = preload("res://sound/ding1.mp3")
@onready var ding2: AudioStream = preload("res://sound/ding2.mp3")

@export var target: RigidBody2D
@export var baseFollowSpeed: float = 5.0  # Base follow speed
@export var maxFollowSpeed: float = 20.0  # Maximum follow speed
@export var velocityThreshold: float = 500.0  # Velocity at which max follow speed is reached
@export var yOffset: float = 200.0 
@export var panDuration: float = 6.0  # Duration of the initial pan in seconds

@onready var countLabel:RichTextLabel = $UI/CountLabel
@onready var menuSFX:AudioStreamPlayer = $MenuSFX

var isPanning: bool = true  # Flag to track if the camera is panning
var panStartTime: float = 0.0  # Time when the pan started
var elapsedTime:float = 0.0
var lastUpdateTime: int = -1 
var gameStarted:bool = false

func _ready():
	startGame()
	
func startGame():
	gameStarted = true
	# Start the camera at maxLevelSizeY
	position.y = Global.maxLevelSizeY
	
	# Record the start time of the pan
	panStartTime = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	updateUI()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", target.global_position.y + yOffset, panDuration)
	tween.finished.connect(_on_pan_finished)
	
	

func _on_pan_finished():
	countLabel.visible = false
	isPanning = false  # Stop panning once the tween is complete

func updateUI():
	if !gameStarted: return
	var remainingTime = int(max(0.0, panDuration - elapsedTime))
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
		elapsedTime = (Time.get_ticks_msec() / 1000.0) - panStartTime
		
		if int(elapsedTime) > lastUpdateTime:
			lastUpdateTime = int(elapsedTime)
			updateUI()
		return  
		
	if target:
		var velocity = target.linear_velocity.length()
		var dynamicFollowSpeed = lerp(baseFollowSpeed, maxFollowSpeed, clamp(velocity / velocityThreshold, 0.0, 1.0))
		position.y = lerp(position.y, target.global_position.y + yOffset, dynamicFollowSpeed * delta)
		if position.y > Global.maxLevelSizeY: position.y = Global.maxLevelSizeY
