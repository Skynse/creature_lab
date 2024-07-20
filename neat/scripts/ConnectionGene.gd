extends Resource

class_name ConnectionGene

@export var weight: float
@export var enabled: bool = true # default state

func _init(_weight: float =0.0, _enabled: bool = true):
	weight = _weight
	enabled = _enabled
	
func _to_string():
	return "ConnectionGene(link_id=%d, weight=%f, enabled=%s)" % [self.link_id, self.weight, str(self.enabled)]
	
func _to_dict() -> Dictionary:
	return {
		"weight": weight,
		"enabled": enabled
	}

func _from_dict(dict: Dictionary):
	weight = dict.get("weight", 0.0)
	enabled = dict.get("enabled", true)
