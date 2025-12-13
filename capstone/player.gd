extends CharacterBody2D

# SETTINGS
# Adjust these x values to match the CENTER of the lanes in your background image
# Assuming 540px width screen: Left=90, Center=270, Right=450
var lane_positions = [90, 270, 450] 
var current_lane = 1 # Start in the middle (0, 1, 2)

func _ready():
	# Snap to starting position
	position = Vector2(lane_positions[current_lane], 800) 

func _input(event):
	if Input.is_action_just_pressed("move_left"):
		change_lane(-1)
	elif Input.is_action_just_pressed("move_right"):
		change_lane(1)

func change_lane(direction):
	var new_lane = current_lane + direction
	# Clamp ensures we don't go outside the 3 lanes
	new_lane = clamp(new_lane, 0, 2)
	
	if new_lane != current_lane:
		current_lane = new_lane
		update_position()

func update_position():
	# Instant movement (teleport) as per design goals
	position.x = lane_positions[current_lane]
