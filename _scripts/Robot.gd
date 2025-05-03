extends Node2D

# Preload sounds
@onready var fireRocket: AudioStream = preload("res://sound/rocket_fire.mp3")

@onready var rocketScene:PackedScene = preload("res://scenes/rocket.tscn")  
@export var spawnInterval: float = 2.0  
@export var shootRight:bool = true

@onready var audioPlayer:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var rocketMarker: Marker2D = $RocketMarker
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

var spawnTimer: Timer  

func _ready() -> void:
	spawnTimer = Timer.new()
	spawnTimer.wait_time = spawnInterval
	spawnTimer.autostart = true
	spawnTimer.one_shot = false
	spawnTimer.timeout.connect(_on_spawn_timer_timeout)  
	add_child(spawnTimer)
	
	animPlayer.animation_finished.connect(_on_animation_finished)

func _on_spawn_timer_timeout() -> void:
	animPlayer.play("shoot")
	audioPlayer.stream = fireRocket
	audioPlayer.play()

func spawnRocket() -> void:
	var rocket:Rocket = rocketScene.instantiate()
	rocket.global_position = rocketMarker.global_position
	if !shootRight:
		rocket.moveRight = false
		rocket.scale.x *= -1
	get_parent().add_child(rocket)

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "shoot":
		animPlayer.play("idle")
		animPlayer.animation_finished.disconnect(_on_animation_finished)
