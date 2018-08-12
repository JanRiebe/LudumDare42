extends Node2D


export (String) var sceneFolder = "res://"

var runningLevel = null

func _ready():
	startMainMenu()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


	
func instantiateScene(levelName):
	if(runningLevel != null):
		runningLevel.queue_free()
	var scene = load(sceneFolder+levelName+".tscn")
	var scene_instance = scene.instance()
	add_child(scene_instance)
	return scene_instance

func startLevel():
	runningLevel = instantiateScene("GameControl")

func startMainMenu():
	runningLevel = instantiateScene("TitleMenu")
	
func startGameOverScreen():
	runningLevel = instantiateScene("TitleMenu")
	
func startOptionsMenu():
	runningLevel = instantiateScene("Options")