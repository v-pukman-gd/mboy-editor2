extends Node2D

const H_LINE_COLOR = Color(230/255.0, 230/255.0, 230/255.0, 1)
const H_LINE_WIDTH = 2

const V_LINE_COLOR = Color(250/255.0, 250/255.0, 250/255.0, 0.15)
const V_LINE_WIDTH = 1

const BG_COLOR = Color(200/255.0, 200/255.0, 200/255.0, 1)

onready var bar = get_node("../")

func _ready():
	update()

func get_bg_color():
	#var color_value = bar.index/4.0 - floor(bar.index/4.0)
	#return BG_COLOR.linear_interpolate(Color(0.2,0.2,0.2), color_value)
	
#	if (bar.index+1)%2 == 1:
#		return BG_COLOR.linear_interpolate(Color(0,0,0), 0)
#	else:
#		return BG_COLOR.linear_interpolate(Color(0,0,0), 0.3)
		
	return BG_COLOR #.linear_interpolate(Color(0,0,0), 0.1)
		
func _draw():
	var rect = Rect2(0, 0, bar.get_width(), bar.get_grid_height())
	draw_rect(rect, get_bg_color())
	
	var section_color = get_bg_color().linear_interpolate(Color(0,0,0), 0.1)

	var cell_counter = 0
	for x in range(bar.get_cells_count() + 1):
		var col_pos = x * EDITOR_BAR_C.CELL_WIDTH

		if cell_counter >= EDITOR_BAR_C.CELLS_IN_QUARTER_COUNT and cell_counter < EDITOR_BAR_C.CELLS_IN_QUARTER_COUNT*2 and x < bar.get_cells_count(): 
			draw_rect(Rect2(col_pos, 0, EDITOR_BAR_C.CELL_WIDTH, bar.get_grid_height()), section_color)
		
		cell_counter += 1
		if cell_counter >= EDITOR_BAR_C.CELLS_IN_QUARTER_COUNT*2: cell_counter = 0
		
		var w = V_LINE_WIDTH
		#if x == 0: w *= 2
		
		var c = V_LINE_COLOR
		if x == 0: c = H_LINE_COLOR
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, bar.get_grid_height()), c, w)

	for y in range(2):
		var row_pos = y * EDITOR_BAR_C.CELL_HEIGHT
		draw_line(Vector2(0, row_pos), Vector2(bar.get_width(), row_pos), H_LINE_COLOR, H_LINE_WIDTH)



