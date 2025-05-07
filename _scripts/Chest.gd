extends Node2D

var coinScene: PackedScene = preload("res://scenes/gold_coin.tscn")

@export var numOfCoinsToSpawn: int = 1000
@onready var animPlayer: AnimationPlayer = $Body/AnimationPlayer
@onready var audioPlayer: AudioStreamPlayer2D = $AudioStreamPlayer2D

#func _ready() -> void:
	#open()

func open():
	animPlayer.play("open")
	audioPlayer.play()
	
	# Spawn coins
	for i in range(numOfCoinsToSpawn):
		# Create a timer for each coin using get_tree().create_timer()
		var delay = randf_range(1.0, 10.0) # Random delay between 1 and 10 seconds
		var timer = get_tree().create_timer(delay)
		timer.timeout.connect(_fire_coin)

func _fire_coin() -> void:
	var coin:RigidBody2D = coinScene.instantiate()
	add_child(coin)
	
	# Randomize spawn position slightly to prevent stacking
	var random_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	coin.position = Vector2(0, 0) + random_offset # Spawn near (0, 0) in local space
	
	var angle = randf_range(-90, 135) # Random angle in degrees
	var force = randf_range(1000, 1200) # Random force magnitude
	var impulse = Vector2(cos(deg_to_rad(angle)), -sin(deg_to_rad(angle))) * force
	coin.apply_force(impulse,Vector2.ZERO)

func reset():
	animPlayer.play("RESET")
	
func hop():
	animPlayer.play("hop")
