extends Node2D

@onready var pupil: Node2D = $Pupil

func _process(_delta: float) -> void:
	# Calculate the direction to the target
	var direction = (Global.player.global_position - global_position).normalized()
	# Set the rotation to point toward the target
	rotation = direction.angle()
	pupil.rotation = -rotation
