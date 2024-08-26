extends Node

@export var swimmer_node: PackedScene
@onready var time_start = Time.get_unix_time_from_system()
@onready var control
var population_size = 20
var birds = []
var file_path# =  "res://saves/best_genome0.res"
var initial_genome: Genome
func _ready():
	control = get_parent().get_node("CanvasLayer/Control")
	if file_path:
		initial_genome = Genome.new(1, 2)
		initial_genome.generate()
		initial_genome.load_from_resource(file_path) # Load genome from file
		
	else:
		initial_genome = Genome.new(1, 2)
		initial_genome.generate()  # Generate initial genome
	
	# Create bird instances
	for i in range(population_size):
		var bird = swimmer_node.instantiate()
		bird.genome = initial_genome.clone()  # Assign the same initial genome to each bird
		add_child(bird)
		birds.append(bird)
		
		# Set initial position
		bird.global_position = Vector3(randf_range(0, 0), 10, randf_range(0, 0))
		
	# No need to update genomes since all birds start with the same genome

func _physics_process(delta):
	if file_path:
		control.visualize_network(initial_genome, initial_genome.get_nodes())
	for bird in birds:
		bird.flap()
		
	if Input.is_action_just_pressed("save"):
		birds[0].genome.save("res://saves/flip.neat")
	
	# Check if it's time to evolve
	if file_path: return
	if Time.get_unix_time_from_system() - time_start > 3:  # Evolve every 10 seconds
		evolve_population()
		time_start = Time.get_unix_time_from_system()

func evolve_population():
	# Calculate fitness for each bird
	for i in range(population_size):
		var fitness = calculate_fitness(birds[i])
		birds[i].genome.set_fitness(fitness)
	
	# Sort birds by fitness
	control.visualize_network(birds[0].genome, birds[0].genome.get_nodes())
	birds.sort_custom(func(a, b): return a.genome.fitness > b.genome.fitness)
	
	# Keep the top 50% as parents
	var parents = birds.slice(0, population_size / 2)
	
	# Create new population through crossover and mutation
	var new_population = []
	for i in range(population_size):
		var parent1 = parents[randi() % parents.size()].genome
		var parent2 = parents[randi() % parents.size()].genome
		
		# Perform crossover
		var child_genome = Neat.genomic_crossover(parent1, parent2)
		
		# Mutate the child
		child_genome.mutate(Brain.new(1, 2, population_size)._hyperparams.mutation_probabilities)
		
		new_population.append(child_genome)
	
	# Update bird genomes with the new population
	for i in range(population_size):
		birds[i].genome = new_population[i]
		birds[i].global_position = Vector3(randf_range(0, 0), 10, randf_range(-1, 1))
	
	# Optionally visualize the best network
	

func calculate_fitness(bird):
	return bird.calculate_fitness()
