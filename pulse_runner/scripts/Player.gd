extends CharacterBody2D

# List of horizontal positions for each lane.  Adjust these values to
# correspond to your chosen resolution.  The player will snap to these
# x‑coordinates when switching lanes.
var lane_positions: Array = [100.0, 270.0, 440.0]

# Index of the currently occupied lane (0 = left, 1 = middle, 2 = right).
var current_lane: int = 1

func _ready() -> void:
    """Called when the node enters the scene tree.

    Position the player near the bottom of the screen and centered in the
    starting lane.  The y value positions the player above the bottom
    boundary.  You may tweak this value in the editor if needed.
    """
    position = Vector2(lane_positions[current_lane], 800.0)


func _unhandled_input(event: InputEvent) -> void:
    """Handle player input for lane switching.

    The built‑in actions `ui_left` and `ui_right` are used instead of
    custom actions so that the project works out of the box without
    additional InputMap configuration.  If the game is not currently
    running (for example during the tutorial) input is ignored by the
    MainGame script.  It still triggers a lane change here but the
    behaviour is harmless.
    """
    if event.is_action_pressed("ui_left"):
        change_lane(-1)
    elif event.is_action_pressed("ui_right"):
        change_lane(1)


func change_lane(direction: int) -> void:
    """Move the player left or right by updating the lane index.

    The `direction` parameter should be ‑1 to move left or +1 to move right.
    The lane index is clamped to stay within the bounds of the array.  If
    the lane actually changes the player's x‑position is updated to the
    corresponding value in `lane_positions`.  Movement is instantaneous
    per the design specification to ensure tight control when obstacles
    spawn on the beat.
    """
    var new_lane: int = clamp(current_lane + direction, 0, lane_positions.size() - 1)
    if new_lane != current_lane:
        current_lane = new_lane
        position.x = lane_positions[current_lane]