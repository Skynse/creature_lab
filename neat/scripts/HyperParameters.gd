extends Object
class_name Hyperparameters

var delta_threshold: float
var distance_weights: Dictionary
var default_activation: String
var max_fitness: float
var max_generations: float
var max_fitness_history: int
var breed_probabilities: Dictionary
var mutation_probabilities: Dictionary

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func _init():
	delta_threshold = 1.5
	distance_weights = {
		"edge": 1.0,
		"weight": 1.0,
		"bias": 1.0
	}
	default_activation = "sigmoid"  # Assuming sigmoid is defined elsewhere
	max_fitness = INF
	max_generations = INF
	max_fitness_history = 30
	breed_probabilities = {
		"asexual": 0.5,
		"sexual": 0.5
	}
	mutation_probabilities = {
		"node": 0.01,
		"edge": 0.09,
		"weight_perturb": 0.4,
		"weight_set": 0.1,
		"bias_perturb": 0.3,
		"bias_set": 0.1
	}

# Assuming sigmoid function is defined elsewhere, but if not, you can define it here:
# static func sigmoid(x: float) -> float:
#     return 1.0 / (1.0 + exp(-x))
