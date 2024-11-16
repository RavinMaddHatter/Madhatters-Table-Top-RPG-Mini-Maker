@tool
extends Node

var t = 0
var animIndex = 0

func _ready():
	pass

func _physics_process(delta):
	if $Rig.isReady:
		$Rig.animIndex = animIndex
		t+= delta * $Rig.fps
		if t > $Rig.frameCount - 1: 
			t = 1
			animIndex+= 1
			if animIndex >= $Rig.animCount:
				animIndex = 0
		$Rig.frameIndex = round(t)
