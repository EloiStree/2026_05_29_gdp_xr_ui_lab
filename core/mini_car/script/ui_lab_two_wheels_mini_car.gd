class_name UiLabTwoWheelsMiniCar
extends CharacterBody3D

signal on_linear_velocity_updated(linear_velocity: float)
signal on_angular_velocity_updated(angular_velocity: float)
signal on_left_wheel_percent_power_updated(percent_power: float)
signal on_right_wheel_percent_power_updated(percent_power: float)
signal on_left_wheel_degree_per_second_updated(degree_per_second: float)
signal on_right_wheel_degree_per_second_updated(degree_per_second: float)
signal on_left_wheel_current_rotation_updated(rotation_in_degree_total: float)
signal on_right_wheel_current_rotation_updated(rotation_in_degree_total: float)
signal on_screen_display_128x64_set_request(array_1d_128x64:Array[bool])
signal on_screen_display_128x64_print_request(array:Array[bool], text:String, letter_color:bool, use_background:bool, top_left_text_corner:Vector2i)
signal on_color_request_for_the_car_style(color_to_apply:Color)

signal on_position_updated(new_position: Vector3)
signal on_rotation_quaternion_updated(new_rotation: Quaternion)
signal on_rotation_euler_updated(new_rotation: Vector3)
signal on_car_id_updated(new_car_id: int)

## I am signal that request the game behind the car to fire something.
## Read the manual of the current game for more information.
signal on_fire_request()

func fire():
	on_fire_request.emit()

func set_car_color(color:Color):
	var color_no_alpha :Color = Color(color.r,color.g,color.b,1)
	on_color_request_for_the_car_style.emit(color_no_alpha)
	
## I am a methode that if the screen is present relay the request of printing text in 6x8
func print_text(array:Array[bool], text:String, letter_color:bool=true, use_background:bool=true, top_left_text_corner:Vector2i=Vector2i.ZERO):
		on_screen_display_128x64_print_request.emit(
			array,
			text,
			letter_color,
			use_background,
			top_left_text_corner
		)

@export_range(-1.0, 1.0,0.0001) var _left_wheel_percent_power: float = 0.0
@export_range(-1.0, 1.0,0.0001) var _right_wheel_percent_power: float = 0.0

@export var _use_fake_gravity:bool=true
@export var _fake_linear_gravity: float = 0.2
@export var _character_to_move: CharacterBody3D
@export var _rotation_per_second_in_degree: float = 720.0
@export var _car_center_reference_node: Node3D
@export var _left_wheel_reference_node: Node3D
@export var _right_wheel_reference_node: Node3D
@export var _right_wheel_top_radius_reference_node: Node3D

@export var _raycast_front_left_wheel: RayCast3D
@export var _raycast_front_right_wheel: RayCast3D
@export var _car_center_ground_reference_node: Node3D
@export var use_random_color_syle_at_ready:bool=true

@export_group("Debug")
@export var _distance_between_wheels_in_mm: float = 70.0
@export var _radius_of_wheels_in_mm: float = 16.6
@export var _diameter_of_wheels_in_mm: float = 33.2
@export var _circumference_of_wheels_in_mm: float = 0.0
@export var _max_wheel_speed_in_meter_per_sec: float = 0.0

@export var _left_rotation_in_degree_total: float = 0.0
@export var _right_rotation_in_degree_total: float = 0.0
@export var _car_id: int = 0
@export var _car_position: Vector3 = Vector3.ZERO
@export var _car_rotation: Quaternion = Quaternion.IDENTITY
@export var _car_euler: Vector3 = Vector3.ZERO


# Internal state
var _distance_between_wheels_in_meter: float = 0.07


func _ready() -> void:
	if not _character_to_move:
		push_error("_character_to_move is not assigned!")
		return
	if use_random_color_syle_at_ready:
		randomize()
		set_car_color(Color(randi() % 256 / 255.0, randi() % 256 / 255.0, randi() % 256 / 255.0))
	refresh_wheel_parameters()


## Recompute the distance between the anchor point to move in real worlds units.
func refresh_wheel_parameters() -> void:
		
	var left_wheel = _left_wheel_reference_node.global_position
	var right_wheel = _right_wheel_reference_node.global_position
	var radius_point = _right_wheel_top_radius_reference_node.global_position
	
	_distance_between_wheels_in_mm = abs(left_wheel.distance_to(right_wheel) * 1000.0)
	_radius_of_wheels_in_mm = (right_wheel.distance_to(radius_point)) * 1000.0
	_diameter_of_wheels_in_mm = _radius_of_wheels_in_mm * 2.0
	_circumference_of_wheels_in_mm = _diameter_of_wheels_in_mm * PI
	
	_max_wheel_speed_in_meter_per_sec = _circumference_of_wheels_in_mm * \
									   (_rotation_per_second_in_degree / 360.0) * 0.001
	
	_distance_between_wheels_in_meter = _distance_between_wheels_in_mm / 1000.0
	
	

## I am method that allows to update the screen of the mini car with a new texture, 
## where the texture is a 1D array of boolean values representing the pixels of the screen,
## Only works is designer did put a screen on the car.
func set_screen_128x64_to(array_1d_128x64:Array[bool]):
	on_screen_display_128x64_set_request.emit(array_1d_128x64)

	
## Allows to control the motor speed of the left wheel from -1.0 to 1.0, where 1.0 is full forward, -1.0 is full backward, and 0.0 is stopped.
func set_left_wheel_percent_power(percent_power: float) -> void:
	_left_wheel_percent_power = clamp(percent_power, -1.0, 1.0)

## Allows to control the motor speed of the right wheel from -1.0 to 1.0, where 1.0 is full forward, -1.0 is full backward, and 0.0 is stopped.
func set_right_wheel_percent_power(percent_power: float) -> void:
	_right_wheel_percent_power = clamp(percent_power, -1.0, 1.0)


## allos to control the motor speed of both motor with a single function, where each percent power is from -1.0 to 1.0, where 1.0 is full forward, -1.0 is full backward, and 0.0 is stopped.
func set_both_wheels_percent_power(left_percent_power: float, right_percent_power: float) -> void:
	set_left_wheel_percent_power(left_percent_power)
	set_right_wheel_percent_power(right_percent_power)

## Compute the max wheel speec in metter per seconds from a given rotation angle per degree.
func set_max_wheel_speed_in_meter_from_rotation_angle_in_degree_per_seconds(new_rotation_per_second_in_degree: float) -> void:
	_rotation_per_second_in_degree = new_rotation_per_second_in_degree
	_max_wheel_speed_in_meter_per_sec = _circumference_of_wheels_in_mm * \
									   (_rotation_per_second_in_degree / 360.0) * 0.001


func set_max_wheel_speed_in_meter_per_sec(new_max_wheel_speed_in_meter_per_sec: float) -> void:
	## untested
	_max_wheel_speed_in_meter_per_sec = new_max_wheel_speed_in_meter_per_sec
	_rotation_per_second_in_degree = (_max_wheel_speed_in_meter_per_sec * 1000.0 * 360.0) / _circumference_of_wheels_in_mm

## SIMULATE CONTROLLER OF FOUR BUTTONS OF KS4036 (FRONT LEFT, FRONT RIGHT, BACK LEFT, BACK RIGHT)
func set_with_four_buttons(front_left: bool, front_right: bool, back_left: bool, back_right: bool) -> void:
	
	if front_left 		and front_right 		and back_left 		and back_right:
		set_both_wheels_percent_power(0,0)

	elif not front_left and front_right 		and back_left 		and back_right:
		set_both_wheels_percent_power(-1,0)

	elif front_left 	and not front_right 	and back_left 		and back_right:
		set_both_wheels_percent_power(0,-1)

	elif not front_left and not front_right 	and back_left 		and back_right:
		set_both_wheels_percent_power(-1,-1)

	elif front_left 	and front_right 		and not back_left 	and back_right:
		set_both_wheels_percent_power(1,0)

	elif not front_left and front_right 		and not back_left 	and back_right:
		set_both_wheels_percent_power(0,0)

	elif  front_left 	and not front_right 	and not back_left 	and back_right:
		set_both_wheels_percent_power(1,-1)

	elif not front_left and not front_right 	and not back_left 	and back_right:
		set_both_wheels_percent_power(0,-1)


	elif front_left 	and front_right 		and back_left 		and not back_right:
		set_both_wheels_percent_power(0,1)

	elif not front_left and front_right 		and back_left 		and not  back_right:
		set_both_wheels_percent_power(-1,1)

	elif front_left 	and not front_right 	and back_left 		and not  back_right:
		set_both_wheels_percent_power(0,0)

	elif not front_left and not front_right 	and back_left 		and not  back_right:
		set_both_wheels_percent_power(-1,0)

	elif front_left 	and front_right 		and not back_left 	and not  back_right:
		set_both_wheels_percent_power(1,1)

	elif not front_left 	and front_right 		and not back_left 	and not  back_right:
		set_both_wheels_percent_power(0,1)

	elif  front_left 	and not front_right 	and not back_left 	and not  back_right:
		set_both_wheels_percent_power(1,0)

	elif not front_left and not front_right 	and not back_left 	and not  back_right:
		set_both_wheels_percent_power(0,0)
	pass


## I am a methode that allows to control the motor from a single joystick input in Vector 2.
## Y axis is up for positive and down for negative, X axis is right for positive and left for negative.
func set_with_one_joystick_using_a_threshold_of_50_percent(joystick_input: Vector2):
	## BAD Should be implemented to have  
	set_with_one_joystick_using_a_boolean_threshold(joystick_input, 0.5)

## I am a methode that allows to control the motor from a single joystick input in Vector 2.
## But using a threshold to determine the direction of the movement, where the threshold is a value between 0.0 and 1.0, and the joystick input is a Vector2 where X axis is right for positive and left for negative, and Y axis is up for positive and down for negative.
## Y axis is up for positive and down for negative, X axis is right for positive and left for negative.
func set_with_one_joystick_using_a_boolean_threshold(joystick_input: Vector2, threshold: float):
	var is_left = joystick_input.x < -threshold
	var is_right = joystick_input.x > threshold
	var is_forward = joystick_input.y >threshold
	var is_backward = joystick_input.y <-threshold

	if is_left and is_forward:
		set_both_wheels_percent_power(0.5, 1.0)  
	elif is_right and is_forward:
		set_both_wheels_percent_power(1.0, 0.5)  
	elif is_left and is_backward:
		set_both_wheels_percent_power(-0.5, -1.0)  
	elif is_right and is_backward:
		set_both_wheels_percent_power(-1.0, -0.5)

	elif is_left and not is_right:
		set_both_wheels_percent_power(0.0, 1.0)  
	elif is_right and not is_left:
		set_both_wheels_percent_power(1.0, 0.0)  
	elif is_forward and not is_backward:
		set_both_wheels_percent_power(1.0, 1.0)  
	elif is_backward and not is_forward:
		set_both_wheels_percent_power(-1.0, -1.0)
	else :
		set_both_wheels_percent_power(0.0, 0.0)


func set_with_one_joystick(joystick_input: Vector2):
	var forward = joystick_input.y          
	var turn   = -joystick_input.x            	

	if joystick_input.length() < 0.1:
		set_both_wheels_percent_power(0.0, 0.0)
		return
	
	var left_wheel  = forward - turn
	var right_wheel = forward + turn
	
	var max_power = max(abs(left_wheel), abs(right_wheel))
	if max_power > 1.0:
		left_wheel  /= max_power
		right_wheel /= max_power
	
	set_both_wheels_percent_power(left_wheel, right_wheel)


func set_wheels(left_joystick:float, right_joystick:float)->void:
	set_both_wheels_percent_power(left_joystick, right_joystick)

## I am a methode that allows to control the motor from two joystick input in Vector 2
## With only the y axis used for the movement, where the left joystick controls the left wheel and the right joystick controls the right wheel. Y axis is up for positive and down for negative, X axis is right for positive and left for negative.
func set_with_double_joystick_2d(left_joystick: Vector2, right_joystick: Vector2):
	set_both_wheels_percent_power(left_joystick.y, right_joystick.y)
	


func _physics_process(delta: float) -> void:
	if not _character_to_move:
		return


	refresh_wheel_parameters()
	
	# ROBOT CONTROL AND ODEMTRY CALCULATIONS
	# DIFFERNTIAL DRIVE KINEMATIC CALCULATIONS
	# SOURCE https://youtu.be/LrsTBWf6Wsc?t=1098

	# === Get input (-1.0 to 1.0) ===
	var left_input = _left_wheel_percent_power
	var right_input = _right_wheel_percent_power
	
	left_input = clamp(left_input, -1.0, 1.0)
	right_input = clamp(right_input, -1.0, 1.0)
	
	# === Wheel linear velocities (m/s) ===
	var left_speed: float = left_input * _max_wheel_speed_in_meter_per_sec
	var right_speed: float = right_input * _max_wheel_speed_in_meter_per_sec
	
	# === Differential drive kinematics ===
	var linear_velocity = (left_speed + right_speed) * 0.5          # m/s
	var angular_velocity = (right_speed - left_speed) / _distance_between_wheels_in_meter  # rad/s
	
	# === Apply rotation ===
	_character_to_move.rotation.y += angular_velocity * delta
	
	# Apply linear velocity in forward direction
	var forward_direction = -_character_to_move.global_transform.basis.z
	_character_to_move.velocity.x = forward_direction.x * linear_velocity
	_character_to_move.velocity.z = forward_direction.z * linear_velocity
	
	if _use_fake_gravity and not _character_to_move.is_on_floor():
		_character_to_move.velocity.y -= _fake_linear_gravity * delta

	_character_to_move.move_and_slide()
				
	on_linear_velocity_updated.emit(linear_velocity)
	on_angular_velocity_updated.emit(angular_velocity)
	on_left_wheel_percent_power_updated.emit(_left_wheel_percent_power)
	on_right_wheel_percent_power_updated.emit(_right_wheel_percent_power)
	on_left_wheel_degree_per_second_updated.emit(left_input * _rotation_per_second_in_degree)
	on_right_wheel_degree_per_second_updated.emit(right_input * _rotation_per_second_in_degree)

	_left_rotation_in_degree_total += left_input * _rotation_per_second_in_degree * delta
	_right_rotation_in_degree_total += right_input * _rotation_per_second_in_degree * delta

	_left_rotation_in_degree_total = fmod(_left_rotation_in_degree_total, 360.0)
	_right_rotation_in_degree_total = fmod(_right_rotation_in_degree_total, 360.0)
	
	on_left_wheel_current_rotation_updated.emit(_left_rotation_in_degree_total)
	on_right_wheel_current_rotation_updated.emit(_right_rotation_in_degree_total)

	_car_id = get_instance_id()
	_car_position = get_car_position()
	_car_rotation = get_car_rotation()
	_car_euler = get_car_euler()
	on_position_updated.emit(_car_position)
	on_rotation_quaternion_updated.emit(_car_rotation)
	on_rotation_euler_updated.emit(_car_euler)
	on_car_id_updated.emit(_car_id)


func set_motor_left_foward_on() -> void:
	set_left_wheel_percent_power(1.0)

func set_motor_left_backward_on() -> void:
	set_left_wheel_percent_power(-1.0)

func set_motor_right_forward_on() -> void:
	set_right_wheel_percent_power(1.0)  

func set_motor_right_backward_on() -> void:
	set_right_wheel_percent_power(-1.0)

func set_motor_left_forward(is_on: bool) -> void:
	set_left_wheel_percent_power(1.0 if is_on else 0.0)

func set_motor_left_backward(is_on: bool) -> void:
	set_left_wheel_percent_power(-1.0 if is_on else 0.0)

func set_motor_right_forward(is_on: bool) -> void:
	set_right_wheel_percent_power(1.0 if is_on else 0.0)

func set_motor_right_backward(is_on: bool) -> void:
	set_right_wheel_percent_power(-1.0 if is_on else 0.0)

func set_motors_off() -> void:
	set_left_wheel_percent_power(0.0)
	set_right_wheel_percent_power(0.0)
	
#--------------------------------

signal on_left_line_sensor_color_updated(new_color: Color)
signal on_right_line_sensor_color_updated(new_color: Color)

@export var _front_wheel_left_distance: float = 0.0
@export var _front_wheel_right_distance: float = 0.0
@export var _color_under_left_color: Color = Color(0, 0, 0, 0)
@export var _color_under_right_color: Color = Color(0, 0, 0, 0)



func set_left_line_sensor_color(new_color: Color) -> void:
	_color_under_left_color = new_color
	on_left_line_sensor_color_updated.emit(new_color)


func set_right_line_sensor_color(new_color: Color) -> void:
	_color_under_right_color = new_color
	on_right_line_sensor_color_updated.emit(new_color)

func get_front_wheel_left_distance()-> float:
	_front_wheel_left_distance = get_distance_from_raycast(_raycast_front_left_wheel)
	return _front_wheel_left_distance

func get_front_wheel_right_distance()-> float:
	_front_wheel_right_distance = get_distance_from_raycast(_raycast_front_right_wheel)
	return _front_wheel_right_distance

func get_left_line_sensor_color()-> Color:
	return _color_under_left_color
func get_right_line_sensor_color()-> Color:
	return _color_under_right_color

func get_center_wheel_forward_node() -> Node3D:
	return _car_center_reference_node

func get_center_wheel_ground_forward_node() -> Node3D:
	return _car_center_ground_reference_node


func get_distance_from_raycast(raycast: RayCast3D) -> float:
	if raycast.is_colliding():
		return raycast.get_collision_point().distance_to(raycast.global_transform.origin)
	else:
		return 0.0  
		


func get_car_id()->int:
	return get_instance_id()
	
func get_car_position()->Vector3:
	return _car_center_ground_reference_node.global_position
	
func get_car_rotation()->Quaternion:
	return Quaternion.from_euler(_car_center_ground_reference_node.global_rotation)
	
func get_car_euler()->Vector3:
	return _car_center_ground_reference_node.global_rotation
