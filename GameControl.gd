extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (String) var sceneFolder = "res://"


export (int) var numberOfPups = 5

export (float) var shrinkPerSecond = 30
var land
var landRadius = 500
var landCenter


export (float) var preySpawnRatePerSec = 0.1
var preySpawnTimer = 0

var score = 0

var player
var pups = []
var food = []


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	land = $Land
	land.connect("body_exited", self, "_on_body_exited_land")
	land.connect("body_entered", self, "_on_body_entered_land")
	
	
	landCenter = land.position	
	
	player = $Player
	player.position = landCenter
	player.target = player.position
	
	for i in range(0,numberOfPups):
		createPup(landCenter+Vector2(numberOfPups/2 -i,0))
	
	#createPrey(Vector2(400,200))

func _process(delta):
	handlePreySpawning(delta)
	shrinkLand(delta)
	updateInputHint()
	testForGameOver()

func testForGameOver():
	if(!player.isCarryingPup and pups.size() <= 0):
		onGameOver()


func shrinkLand(delta):
	if(landRadius >= 0.1):
		landRadius -= delta * shrinkPerSecond * (landRadius)/5000
	else:
		landRadius = 0
	setLandScale(landRadius)


func handlePreySpawning(delta):
	preySpawnTimer += delta * preySpawnRatePerSec
	if(preySpawnTimer >= 1):
		preySpawnTimer=0
		var vec = getVectorOutsideLand()
		if vec.x>=0:
			createPrey(vec)


func getVectorOutsideLand():
	var vec = Vector2(rand_range(0,get_viewport().size.x), rand_range(0,get_viewport().size.y))
	
	var breakI = 0
	
	while (isPointInsideLand(vec) and breakI < 100):
		vec.x = rand_range(0,get_viewport().size.x)
		vec.y = rand_range(0,get_viewport().size.y)
		breakI += 1
	
	if(breakI == 100):
		print("did not find suitable spot for prey")
		vec = Vector2(-1,-1)
	
	return vec

func isPointInsideLand(point):
	return (landCenter - point).length() < landRadius
	#var space_state = get_world_2d().direct_space_state
	#var result = space_state.intersect_ray(point, point+Vector2(0.1,0.1))
	#if result.size == 0:
	#	return false
	#elif result[collider] != null:
	#	print( result[collider].name)

func createPup(location):
	var p = instantiate("AI", location)
	pups.append(p)

func createPrey(location):
	var p = instantiate("Prey",location)	
	p.connect("body_entered", self, "_on_body_entered_prey")
	p.connect("body_entered", p, "_on_body_entered_prey")


func dropFood(location):
	var newFood = instantiate("DroppedFood",location)
	food.append(newFood)
	newFood.connect("body_entered", newFood, "_on_body_entered_food")
	land.connect("area_exited", newFood, "_on_food_exited_land")
	newFood.connect("body_entered", self, "_on_body_entered_food")



func onFoodDestroyed(foodObject):
	var i = food.find(foodObject)
	if i>=0:
		food.remove(i)


func instantiate(sceneName, location):
	var scene = load(sceneFolder+sceneName+".tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name(sceneName)
	add_child(scene_instance)
	scene_instance.position = location
	print("instantiated "+sceneName)
	return scene_instance
	
	
func _on_body_entered_food(body):
	if body.name != "Player":
		score+=pups.size()
		displayScore()

func _on_body_exited_land(body):
	print("_on_body_exited_land ",body.name)
	var i = pups.find(body)
	body._on_exited_land()
	

func _on_body_entered_land(body):
	if(body.name == "Player"):
		body._on_entered_land()
		

func _on_body_entered_prey(body):
	if(body.name == "Player"):
		body.onCaughtPrey()
		
func playerPickedUpPut(pup):
	print("playerPickedUpPut ",pup.name)
	var i = pups.find(pup)
	if (i>=0): #body is a pup
		player.pickUpPup(pup)
		pups.remove(i)
		
func onPupDied(pup):
	print("onPupDied ",pup.name)
	var i = pups.find(pup)
	if (i>=0): #body is a pup
		pups.remove(i)


func setLandScale(radius):
	land.get_child(1).shape.set_radius( radius)
	land.get_child(0).scale = Vector2(radius/500.0,radius/500.0)
	landRadius = radius
	
func onGameOver():
	get_parent().startGameOverScreen()
	
	
func displayScore():
	var lab = $CanvasLayer.get_node("Score")
	lab.set_text(str(score))
	
func updateInputHint():
	if player.isCarryingPup:
		$CanvasLayer.get_node("InputHint").text = "press Enter to put the cub down"
	elif player.isCarryingFood:
		$CanvasLayer.get_node("InputHint").text = "press Enter to drop food"
	else:
		$CanvasLayer.get_node("InputHint").text = "click with the mouse at fishes to collect food"	