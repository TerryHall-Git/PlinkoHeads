extends Node2D

@onready var success: AudioStream = preload("res://sound/Success.mp3")
@onready var yay: AudioStream = preload("res://sound/Yay.mp3")
@onready var grandPrize: Texture2D = preload("res://artwork/win_messages/GRAND_PRIZE.png")
@onready var menuSFX:AudioStreamPlayer
@onready var musicPlayer:AudioStreamPlayer

var chest:Node2D
var winScreen:Control
var winMessage:TextureRect

@onready var winMessages: Array[Texture2D] = [
	preload("res://artwork/win_messages/CONGRATZ.png"),
	preload("res://artwork/win_messages/EXCELLENT.png"),
	preload("res://artwork/win_messages/NICE_JOB.png"),
	preload("res://artwork/win_messages/YOU_WIN.png")
]

func _ready() -> void:
	menuSFX = get_tree().current_scene.get_node("Camera2D/MenuSFX")
	musicPlayer = get_tree().current_scene.get_node("MusicPlayer")
	chest = get_tree().current_scene.get_node("Chest")
	await get_tree().process_frame
	winScreen = get_tree().current_scene.find_child("Camera2D").get_node("UI/WinScreen")
	winMessage = winScreen.get_node("WinMessage")
	for child in get_children():
		if child.has_signal("player_won"):
			child.player_won.connect(playerWon)

func playerWon(prize: String) -> void:
	print("Player won " + prize)
	menuSFX.stream = yay
	menuSFX.play()
	
	 # Fade out the music before showing the win message
	var tween = get_tree().create_tween()
	tween.tween_property(musicPlayer, "volume_db", -80, 2.0).set_ease(Tween.EASE_OUT)

	# After the fade-out, show the win message and play the success sound
	tween.finished.connect(_on_music_fade_out_finished.bind(prize))

func _on_music_fade_out_finished(prize: String) -> void:
	menuSFX.stream = success
	menuSFX.play()

	if prize == "GRAND_PRIZE":
		winMessage.texture = grandPrize
		chest.open()
	else:
		winMessage.texture = winMessages[randi() % winMessages.size()]
	
	winScreen.visible = true

	# Reset the winMessage scale and rotation
	winMessage.scale = Vector2(0.1, 0.1)
	winMessage.rotation = 0.0

	# Create a tween for the animation
	var tween = get_tree().create_tween()

	# Tween the scale from 0.1 to 1.0 with a bounce ease-out
	tween.tween_property(winMessage, "scale", Vector2(1.0, 1.0), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	# Tween the rotation to spin the message (e.g., 360 degrees)
	tween.tween_property(winMessage, "rotation", 2 * PI, 1.0).set_ease(Tween.EASE_OUT)
	
	# Fade music back in slowly
	var tween2 = get_tree().create_tween()
	tween2.tween_property(musicPlayer, "volume_db", 0.0, 6.0).set_ease(Tween.EASE_IN)
