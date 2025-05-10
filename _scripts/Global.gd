extends Node

var maxLevelSizeY: float = 4500.0
var player: RigidBody2D
var canPlay: bool = false
var imgPath: String = ""
var config: ConfigFile

func _ready() -> void:
	config = ConfigFile.new()
	get_tree().scene_changed.connect(_gameLoaded) #load image on restart
	#loadImage() #Optional - load image when game is first started
	
func _gameLoaded():
	loadImage()
	

func loadImage():
	var err = config.load("user://saveData.cfg")
	if err == OK:
		# Load the saved imgPath if it exists
		if config.has_section_key("player", "imgPath"):
			imgPath = config.get_value("player", "imgPath", "")
			await get_tree().process_frame
			if imgPath != "":
				var image = Image.new()
				if image.load(imgPath) == OK:
					print("Loading photo from: ", imgPath)
					var imgTexture = ImageTexture.create_from_image(image)
					var photoSprite1: Sprite2D = player.get_node("mask/photo")
					var photoSprite2: Sprite2D = get_tree().current_scene.get_node("Camera2D/UI/MainMenu/mask/photo")
					photoSprite1.texture = imgTexture
					photoSprite2.texture = imgTexture
				else:
					print("Failed to load image from: ", imgPath)
	else:
		print("Failed to load config file: ", err)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !get_tree().paused:
			get_tree().current_scene.get_node("Camera2D/UI/MainMenu").visible = true
			get_tree().paused = true

func updateImgPath(val: String) -> void:
	imgPath = val
	config.set_value("player", "imgPath", imgPath)
	var err = config.save("user://saveData.cfg")
	if err != OK:
		print("Failed to save config file: ", err)
