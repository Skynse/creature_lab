extends Container


var nodes: Dictionary
var node_positions: Dictionary
const NODE_RADIUS = 5
var NETWORK_WIDTH
var NETWORK_HEIGHT
var genome
@onready var graph = get_parent().get_parent()
var node_names = ["dist", "flap_l", "flap_r"]

func _ready():
	NETWORK_WIDTH = graph.size.x - get_parent().get_node("save_button").size.y
	NETWORK_HEIGHT = graph.size.y
	custom_minimum_size = Vector2(NETWORK_WIDTH, NETWORK_HEIGHT)
func _draw():
	if genome == null:
		draw_string(ThemeDB.fallback_font, Vector2(10, 20), "Waiting for data", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		return

	# Generate node positions
	generate_node_positions()

	# Draw connections
	draw_connections()

	# Draw nodes
	draw_nodes()

	# Draw node names and values
	draw_node_info()

func generate_node_positions():
	node_positions.clear()
	
	# Position input nodes
	for i in range(genome.num_inputs):
		var x = 50
		var y = lerp(50.0, NETWORK_HEIGHT - 50.0, float(i) / max(1, genome.num_inputs - 1))
		node_positions[i] = Vector2(x, y)
	
	# Position output nodes
	for i in range(genome.num_outputs):
		var x = NETWORK_WIDTH - 50
		var y = lerp(50.0, NETWORK_HEIGHT - 50.0, float(i) / max(1, genome.num_outputs - 1))
		node_positions[genome.num_inputs + i] = Vector2(x, y)
	
	# Position hidden nodes
	var hidden_count = genome.max_node - genome.num_inputs - genome.num_outputs
	for i in range(hidden_count):
		# Distribute hidden nodes evenly in a grid or fixed positions
		var row = floor(i/10)
		var col = i % 10
		var x = lerp(NETWORK_WIDTH / 3.0, NETWORK_WIDTH * 2.0 / 3.0, float(col) / 9.0)
		var y = lerp(50.0, NETWORK_HEIGHT/2.0 - 50.0, float(row) / max(1, floor(hidden_count/10) - 1))
		node_positions[genome.num_inputs + genome.num_outputs + i] = Vector2(x, y)
func draw_connections():
	for edge in genome.links.keys():
		var i = int(edge.split(",")[0])
		var j = int(edge.split(",")[1])
		
		if node_positions.has(i) and node_positions.has(j):
			var color = Color.GREEN if genome.links[edge].weight > 0 else Color.RED
			if not genome.links[edge].enabled:
				color = Color.GRAY
			draw_line(node_positions[i], node_positions[j], color, 2)

func draw_nodes():
	for node_id in node_positions:
		var color = Color.BLUE if node_id < genome.num_inputs else Color.RED if node_id < genome.num_inputs + genome.num_outputs else Color.WHITE
		draw_circle(node_positions[node_id], NODE_RADIUS, color)

func draw_node_info():
	for node_id in node_positions:
		var pos = node_positions[node_id]
		var name = str(node_id)
		if node_id < genome.num_inputs:
			name = node_names[node_id]
		elif node_id < genome.num_inputs + genome.num_outputs:
			name = node_names[node_id]
		
		draw_string(ThemeDB.fallback_font, pos + Vector2(10, -10), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		
		if nodes.has(node_id):
			var value = truncate(str(nodes[node_id].output))
			draw_string(ThemeDB.fallback_font, pos + Vector2(-20, 10), value, HORIZONTAL_ALIGNMENT_RIGHT, -1, 16, Color.WHITE)

func _process(delta):
	queue_redraw()

func truncate(text: String) -> String:
	return text.substr(0, 5) if len(text) > 5 else text

func visualize_network(new_genome: Genome, new_nodes: Dictionary):
	genome = new_genome
	nodes = new_nodes
	queue_redraw()
