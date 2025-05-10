extends TextureRect

@onready var clickSound1: AudioStream = preload("res://sound/Click1.mp3")  
@onready var clickSound2: AudioStream = preload("res://sound/Click2.mp3") 

var audioPlayer:AudioStreamPlayer

var fileDialog: FileDialog

func _ready() -> void:
	audioPlayer = get_tree().current_scene.get_node("Camera2D/MenuSFX")
	# Get the FileDialog node
	fileDialog = get_tree().current_scene.get_node("FileDialog")
	# Configure the FileDialog to filter for image files
	fileDialog.filters = ["*.png ; PNG Images", "*.jpg ; JPEG Images", "*.jpeg ; JPEG Images"]
	# Set the starting directory to the desktop folder
	# This works on most platforms:
	var desktop_path = OS.get_environment("HOME") + "/Desktop"
	# For Windows, use the USERPROFILE environment variable:
	if OS.get_name() == "Windows":
		desktop_path = OS.get_environment("USERPROFILE") + "/Desktop"
	fileDialog.current_dir = desktop_path
	# Connect the file_selected signal
	fileDialog.file_selected.connect(_on_file_selected)

func _on_mouse_entered() -> void:
	# Change the modulate color to pure white
	modulate = Color(1, 1, 1)
	audioPlayer.stream = clickSound1
	audioPlayer.play()

func _on_mouse_exited() -> void:
	# Change the modulate color to (200, 200, 200)
	modulate = Color(200 / 255.0, 200 / 255.0, 200 / 255.0)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		openFileDialog()
		audioPlayer.stream = clickSound2
		audioPlayer.play()

func openFileDialog():	
	# Open the FileDialog
	fileDialog.popup_centered()

func _on_file_selected(path: String) -> void:
	# Load the selected image as a texture
	var image = Image.new()
	if image.load(path) == OK:
		Global.updateImgPath(path)
		print("loading photo")
		var imgTexture = ImageTexture.create_from_image(image)
		var photoSprite1: Sprite2D = Global.player.get_node("mask/photo")
		var photoSprite2: Sprite2D = get_tree().current_scene.get_node("Camera2D/UI/MainMenu/mask/photo")
		photoSprite1.texture = imgTexture
		photoSprite2.texture = imgTexture
