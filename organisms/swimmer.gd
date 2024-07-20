extends Node3D

@onready var body = $Body
@onready var left_wing = $LeftWing
@onready var right_wing = $RightWing
@onready var left_wing_joint = $LeftWingJoint
@onready var right_wing_joint = $RightWingJoint

@export var flap_force = 100.0
@export var flap_speed = 10.0
@export var max_altitude = 4.0
@export var min_altitude = 1.0
@export var penalty = 10.0

var distance_to_ground = 0
var time_in_altitude_range = 0.0
var fitness = 0.0
var genome: Genome

func _ready():
	setup_joints()

func setup_joints():
	left_wing_joint.node_a = body.get_path()
	left_wing_joint.node_b = left_wing.get_path()
	right_wing_joint.node_a = body.get_path()
	right_wing_joint.node_b = right_wing.get_path()

func _physics_process(delta):
	distance_to_ground = get_distance_to_ground()
	update_fitness(delta)
	flap()

func get_distance_to_ground():
	return body.global_position.y

func update_fitness(delta):
	if min_altitude < distance_to_ground and distance_to_ground < max_altitude:
		time_in_altitude_range += delta
	elif distance_to_ground >= max_altitude:
		fitness -= penalty * delta

func flap():
	var inputs = [distance_to_ground]
	var outputs = genome.forward(inputs)
	
	if outputs[0] > 0.5:
		flap_wing(left_wing, 1)
	elif outputs[0] < -0.5:
		flap_wing(left_wing, -1)
	
	if outputs[1] > 0.5:
		flap_wing(right_wing, 1)
	elif outputs[1] < -0.5:
		flap_wing(right_wing, -1)

func flap_wing(wing: RigidBody3D, direction: int):
	wing.apply_torque(Vector3(0, 0, -flap_force * direction))
	body.apply_force(Vector3.UP * flap_force, wing.global_position - body.global_position)

func calculate_fitness():
	fitness = time_in_altitude_range - (penalty * max(0, distance_to_ground - max_altitude))
	print("Flapper fitness: " + str(fitness))
	return fitness

func reset():
	body.global_position = Vector3(0, 2, 0)  # Start at a slight height
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	left_wing.angular_velocity = Vector3.ZERO
	right_wing.angular_velocity = Vector3.ZERO
	time_in_altitude_range = 0.0
	fitness = 0.0
