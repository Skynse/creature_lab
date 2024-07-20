extends Object
class_name NodeGene

var x: float
var y: float

@export var activation_func: String
@export var bias: float
@export var output: float = 0.0

func sigmoid(_x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func relu(_x: float) -> float:
	return max(0.0, x)

func leaky_relu(_x: float) -> float:
	return max(0.01 * x, x)

var activation_functions = {
	"sigmoid": sigmoid,
	"relu": relu,
	"leaky_relu": leaky_relu
}

func _init(_activation_func: String = "sigmoid", _bias: float = 0 ):
	if _activation_func == null:
		activation_func = "sigmoid"
	else:
		activation_func = _activation_func
	bias = _bias

func duplicate() -> NodeGene:
	var new_node = NodeGene.new(activation_func, bias)
	new_node.x = x
	new_node.y = y
	return new_node
	

func _to_dict() -> Dictionary:
	return {
		"activation_func": activation_func,
		"bias": bias
	}

func _from_dict(dict: Dictionary):
	print(dict)
	activation_func = dict.get("activation_func", "")
	bias = dict.get("bias", 0.0)
