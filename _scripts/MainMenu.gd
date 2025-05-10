extends Control

@onready var openMenuSound: AudioStream = preload("res://sound/MenuOpen.mp3")  
@onready var closeMenuSound: AudioStream = preload("res://sound/MenuClose.mp3")

var audioPlayer:AudioStreamPlayer
var isReady: bool = false
var isTweening:bool = false

func _ready() -> void:
	audioPlayer = get_tree().current_scene.get_node("Camera2D/MenuSFX")

func _process(_delta: float) -> void:
	if !self.visible: return
	if !isReady:
		await get_tree().process_frame
		isReady = true
		return
	if Input.is_action_just_pressed("ui_cancel") && !isTweening: 
		unpause()

func unpause():
	isTweening = true
	audioPlayer.stream = closeMenuSound
	audioPlayer.play()
	# Reverse the scale tween when unpausing
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.1).set_ease(Tween.EASE_IN) #.set_trans(Tween.TRANS_ELASTIC)
	tween.finished.connect(_on_unpause_tween_finished)

func _on_unpause_tween_finished():
	self.visible = false
	get_tree().paused = false
	isReady = false
	isTweening = false

func _on_visibility_changed() -> void:
	if self.visible:
		isTweening = true
		await  get_tree().process_frame
		audioPlayer.stream = openMenuSound
		audioPlayer.play()
		# Scale up with a bounce effect when the menu becomes visible
		self.scale = Vector2(0.1, 0.1)  # Start at a small scale
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		tween.finished.connect(_on_open_tween_finished)
		
func _on_open_tween_finished():
	print("tween finished")
	isTweening = false
