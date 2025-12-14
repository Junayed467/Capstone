extends CharacterBody2D

var lane_positions: Array[float] = []
var current_lane := 1

func _ready() -> void:
	# If MainGame sets lanes at start_game(), this will get overwritten then.
	pass

func set_lane_centers(lanes: Array[float]) -> void:
	lane_positions = lanes
	update_position()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_left"):
		change_lane(-1)
	elif Input.is_action_just_pressed("move_right"):
		change_lane(1)

func change_lane(direction: int) -> void:
	if lane_positions.is_empty():
		return

	var new_lane = clamp(current_lane + direction, 0, lane_positions.size() - 1)
	if new_lane != current_lane:
		current_lane = new_lane
		update_position()

func update_position() -> void:
	if lane_positions.is_empty():
		return
	position.x = lane_positions[current_lane]
	# keep your Y where you want it:
	position.y = 720
