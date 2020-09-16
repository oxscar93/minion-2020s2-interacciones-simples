extends Node2D

const DIAMOND_COUNT = 10
const HOLE_COUNT = 3
const MIN_DISTANCE = 20

var diamond = preload("res://Diamond.tscn")
var hole = preload("res://Hole.tscn")
var constants = preload("res://Constants.gd")

var target = Vector2()
var velocity = Vector2()
var screenSize = Vector2()

func _ready():
	screenSize = get_viewport().get_visible_rect().size
	randomize()
	
func _process(delta):
	pass

func _new_game():
	$StartTimer.start()
	
func game_over():
	$DiamondTimer.stop()	
	$HUD.show_game_over()
	
	_clearGame()
		
func _on_DiamondTimer_timeout():
	_initializeDiamonds()

func _on_TriangleTimer_timeout():	
	_initializeHoles()
	
func _initializePlayer():
	$Circle.start($StartPosition.position)
	
func _initializeDiamonds():	
	var last_diamond
	
	for i in range(DIAMOND_COUNT):
		var new_diamond = diamond.instance()
		
		new_diamond.connect("onDiamondRecolected", self, "_onDiamond_Recolected")
		new_diamond.global_position = _getRandomVector()	
		
		add_child(new_diamond) 
		
		#instancio y luego de un tiempo necesario para que los metodos 
		#de area 2d devuelvan resultados
		#verifico si hay areas solapadas
		
		yield(get_tree().create_timer(0.01), "timeout")
		
		_handleAreaOverlapping(new_diamond, last_diamond, constants.Diamond)
		
		last_diamond = new_diamond
		
func _initializeHoles():	
	var last_hole
	
	for i in range(HOLE_COUNT):
		var new_hole = hole.instance()
		
		new_hole.init($Circle)
		new_hole.global_position = _getRandomVector()
		
		add_child(new_hole)	
		
		#instancio y luego de un tiempo necesario para que los metodos 
		#de area 2d devuelvan resultados
		#verifico si hay areas solapadas
		yield(get_tree().create_timer(0.01), "timeout")
		
		_handleAreaOverlapping(new_hole, last_hole, constants.HOLE)
		
func _onDiamond_Recolected():
	$HUD.updateScore() 

func _on_StartTimer_timeout():
	_initializePlayer()
	_initializeDiamonds()
	_initializeHoles() 
	
	$DiamondTimer.start()
	
func _clearGame():
	$Circle.hide()
	
	get_tree().call_group("triangles", "queue_free")
	get_tree().call_group("diamonds", "queue_free")
	get_tree().call_group("holes", "queue_free")
	
func _handleAreaOverlapping(newArea, lastArea, areaOverlapedName):	
	if (newArea == null):
		return
		
	var areas = newArea.get_overlapping_areas()
		
	for i in areas:
		if (i.get_name() == areaOverlapedName or i.get_name() == constants.PLAYER):
			newArea.global_position = _getRandomVector(newArea.global_position)
			

func _getRandomVector(pos = Vector2()):
	return Vector2(rand_range(pos.x + MIN_DISTANCE, screenSize.x), rand_range(pos.y + MIN_DISTANCE, screenSize.y))	

