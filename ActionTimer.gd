class_name ActionTimer extends Resource

var checker = {}

func ExecOnElapsed(label, timeout, eval_func):
	if CounterElapsed(label, timeout):
		Reset(label)
		eval_func.call()
	else:
		Increment(label)

func CounterElapsed(label, timeout):
	return label in checker and checker[label] > timeout

func Increment(label):
	if label in checker:
		checker[label] += 1
	else:
		checker[label] = 1

func Reset(label):
	checker[label] = 0
