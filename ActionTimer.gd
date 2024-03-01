class_name ActionTimer extends Resource

var checker = {}
var default_timeout = 25

func _init(timeout:int = 25):
	default_timeout = timeout

func ExecOnElapsed(label, eval_func, timeout=default_timeout):
	if CounterElapsed(label, timeout):
		Reset(label)
		eval_func.call()
	else:
		Increment(label)

func CounterElapsed(label, timeout=default_timeout):
	return label in checker and checker[label] > timeout

func GetProgress(label, timeout=default_timeout):
	if label in checker:
		return float(checker[label]) / timeout
	else:
		return 0

func Increment(label):
	if label in checker:
		checker[label] += 1
	else:
		checker[label] = 1

func Reset(label):
	checker[label] = 0
