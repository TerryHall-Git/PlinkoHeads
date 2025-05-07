extends Node2D

@onready var prize1:Texture2D = preload("res://artwork/win_messages/PRIZE1.png")
@onready var prize2:Texture2D = preload("res://artwork/win_messages/PRIZE2.png")
@onready var prize3:Texture2D = preload("res://artwork/win_messages/PRIZE3.png")
@onready var grandPrize: Texture2D = preload("res://artwork/win_messages/GRAND_PRIZE.png")

@onready var burst_green:Texture2D = preload("res://artwork/Sunburst_Green.png")
@onready var burst_blue:Texture2D = preload("res://artwork/Sunburst_Blue.png")
@onready var burst_purple:Texture2D = preload("res://artwork/Sunburst_Purple.png")
@onready var burst_gold:Texture2D = preload("res://artwork/Sunburst_OrangeYellow.png")

@onready var success: AudioStream = preload("res://sound/Success.mp3")
@onready var yay: AudioStream = preload("res://sound/Yay.mp3")
@onready var menuSFX:AudioStreamPlayer
@onready var musicPlayer:AudioStreamPlayer

var chest:Node2D
var winScreen:Control
var winMessage:TextureRect
var winBackground:TextureRect


func _ready() -> void:
	menuSFX = get_tree().current_scene.get_node("Camera2D/MenuSFX")
	musicPlayer = get_tree().current_scene.get_node("MusicPlayer")
	chest = get_tree().current_scene.get_node("Chest")
	await get_tree().process_frame
	winScreen = get_tree().current_scene.find_child("Camera2D").get_node("UI/WinScreen")
	winMessage = winScreen.get_node("WinMessage")
	winBackground = winScreen.get_node("WinBG")
	
	for child in get_children():
		if child.has_signal("player_won"):
			child.player_won.connect(playerWon)

func playerWon(prize: String) -> void:
	Global.canPlay = false
	
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
	
	match prize:
		"PRIZE1":
			winMessage.texture = prize1
			winBackground.texture = burst_purple
			chest.hop()
		"PRIZE2":
			winMessage.texture = prize2
			winBackground.texture = burst_blue
			chest.hop()
		"PRIZE3":
			winMessage.texture = prize3
			winBackground.texture = burst_green
			chest.hop()
		"GRAND_PRIZE":
			winMessage.texture = grandPrize
			winBackground.texture = burst_gold
			chest.open()
	
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
