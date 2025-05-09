extends TextureRect

@onready var clickSound: AudioStream = preload("res://sound/Click1.mp3")  

var audioPlayer:AudioStreamPlayer

var mainMenu:Control

func _ready() -> void:
	mainMenu = self.get_parent()
	audioPlayer = get_tree().current_scene.get_node("Camera2D/MenuSFX")

func _on_mouse_entered() -> void:
	# Change the modulate color to pure white
	modulate = Color(1, 1, 1)
	audioPlayer.stream = clickSound
	audioPlayer.play()

func _on_mouse_exited() -> void:
	# Change the modulate color to (200, 200, 200)
	modulate = Color(200 / 255.0, 200 / 255.0, 200 / 255.0)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.canPlay = false
		mainMenu.unpause()
		get_tree().reload_current_scene()
