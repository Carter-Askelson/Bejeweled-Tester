extends Node2D

@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int




#the piece array
var possible_pieces = [
preload("res://pieces/blue_piece.tscn"),
preload("res://pieces/green_piece.tscn"),
preload("res://pieces/yellow_piece.tscn")
]

#current peices in scene
var all_pieces = []

#touch variables
var first_touch
var touch_released
var controlling = false

var matches = 0

func spawn_pieces():
	for i in width:
		for j in height:
			#choose a random number and store it
			var rand = floor(randf_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instantiate()
			var loops = 0
			while(match_at(i, j, piece.color) && loops < 100):
				rand = floor(randf_range(0, possible_pieces.size()))
				loops +=1
				piece = possible_pieces[rand].instantiate()
			# Instantiate a piece from the array
			
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)
	
func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)
	
	
func is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	all_pieces = make_2d_array()
	spawn_pieces()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	touch_input()
	
	
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
							matches += 1
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color && all_pieces[i][j + 1].color == current_color:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
							matches += 1
	self.get_parent().get_child(8).play()
	get_parent().get_node("destroy_timer").start()
	self.get_parent().get_child(5).text = str(matches)

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
	

	
		
func touch_input():
		if Input.is_action_just_pressed("ui_touch"):
			first_touch = get_global_mouse_position()
			var grid_position = pixel_to_grid(first_touch.x, first_touch.y)
			if is_in_grid(grid_position.x, grid_position.y):
				controlling = true
			else:
				controlling = false
		if Input.is_action_just_released("ui_touch"):
			touch_released = get_global_mouse_position()
			var grid_position = pixel_to_grid(touch_released.x, touch_released.y)
			if is_in_grid(grid_position.x, grid_position.y) && controlling:
				touch_difference(pixel_to_grid(first_touch.x, first_touch.y), grid_position)
		
func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.position = grid_to_pixel(column + direction.x, row + direction.y)
		other_piece.position = grid_to_pixel(column, row)
		find_matches()

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
			
		
func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					
	get_parent().get_node("collapse_timer").start()

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						self.get_parent().get_child(9).play()
						break

func _on_destroy_timer_timeout():
	destroy_matched()
	


func _on_collapse_timer_timeout():
	collapse_columns()


func _on_refill_button_pressed():
		for i in width:
			for j in height:
				if all_pieces[i][j] == null:
					#choose a random number and store it
					var rand = floor(randf_range(0, possible_pieces.size()))
					var piece = possible_pieces[rand].instantiate()
					var loops = 0
					while(match_at(i, j, piece.color) && loops < 100):
						rand = floor(randf_range(0, possible_pieces.size()))
						loops += 1
						piece = possible_pieces[rand].instantiate()
					# Instantiate a piece from the array
					
					add_child(piece)
					piece.position = grid_to_pixel(i, j)
					all_pieces[i][j] = piece
					self.get_parent().get_child(10).play()



func _on_quit_button_pressed():
	get_tree().quit()
