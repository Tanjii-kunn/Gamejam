extends Node2D

# Crosshair script for following mouse position

@export var crosshair_color: Color = Color(1, 0, 0, 0.8)  # Crosshair color, default is semi-transparent red
@export var crosshair_size: float = 10.0  # Crosshair size
@export var crosshair_width: float = 2.0  # Crosshair line width
@export var crosshair_gap: float = 3.0  # Crosshair center gap

func _process(_delta):
	# Update position to mouse position
	global_position = get_global_mouse_position()
	# Force redraw
	queue_redraw()

func _draw():
	# Draw crosshair
	# Horizontal lines
	draw_line(Vector2(-crosshair_size - crosshair_gap, 0), Vector2(-crosshair_gap, 0), crosshair_color, crosshair_width)
	draw_line(Vector2(crosshair_gap, 0), Vector2(crosshair_size + crosshair_gap, 0), crosshair_color, crosshair_width)
	
	# Vertical lines
	draw_line(Vector2(0, -crosshair_size - crosshair_gap), Vector2(0, -crosshair_gap), crosshair_color, crosshair_width)
	draw_line(Vector2(0, crosshair_gap), Vector2(0, crosshair_size + crosshair_gap), crosshair_color, crosshair_width)
	
	# Draw small circle
	draw_circle(Vector2.ZERO, crosshair_gap, crosshair_color) 