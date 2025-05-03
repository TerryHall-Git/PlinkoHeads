extends Node2D

@onready var uLeftJoint:RigidBody2D = $GrappleBody/ULeftJoint
@onready var lLeftJoint:RigidBody2D = $GrappleBody/ULeftJoint/LLeftJoint
@onready var uRightJoint:RigidBody2D = $GrappleBody/URightJoint
@onready var lRightJoint:RigidBody2D = $GrappleBody/URightJoint/LRightJoint

var rotatingBodies: Array = []  # List of bodies to rotate
var rotationSpeeds: Dictionary = {}  # Dictionary to store rotation speeds for each body
var targetRotations: Dictionary = {}  # Dictionary to store target rotations for each body

func _input(event: InputEvent) -> void:
	if event is InputEventKey && Input.is_action_just_released("ui_accept") && Global.canPlay:
		rotateBody(uLeftJoint, 35)
		rotateBody(uRightJoint, -35)
		rotateBody(lLeftJoint, 35)
		rotateBody(lRightJoint, -35)

func rotateBody(rigidBody: RigidBody2D, degrees: float) -> void:
	# Add the body to the rotating list
	if not rotatingBodies.has(rigidBody):
		rotatingBodies.append(rigidBody)
		rotationSpeeds[rigidBody] = degToRad(degrees) / 0.5  # Rotate over 0.5 seconds
		targetRotations[rigidBody] = rigidBody.rotation + degToRad(degrees)  # Set the target rotation

func _physics_process(delta: float) -> void:
	# Update the rotation of each body
	for body in rotatingBodies:
		if body in rotationSpeeds and body in targetRotations:
			# Calculate the rotation step
			var rotationStep = rotationSpeeds[body] * delta

			# Check if the body is close to the target rotation
			if abs(targetRotations[body] - body.rotation) <= abs(rotationStep):
				# Snap to the target rotation and stop rotating
				body.rotation = targetRotations[body]
				rotatingBodies.erase(body)
				rotationSpeeds.erase(body)
				targetRotations.erase(body)
			else:
				# Incrementally rotate the body
				body.rotation += rotationStep

func degToRad(degrees: float) -> float:
	return degrees * PI / 180.0
