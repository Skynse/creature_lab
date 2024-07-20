extends Control

var genome: Genome
var best
@onready var container = $graph/VBoxContainer/Container

func _ready():
	container.genome = genome
	

func visualize_network(_best, nodes):
	best = _best
	container.visualize_network(_best, nodes)

func _on_button_pressed():
	
	if best != null:
		var id = best.adjusted_fitness
		print("saving genome")
		best.save_as_resource("res://saves/best_genome" + str(id)+".res")
	pass # Replace with function body.
