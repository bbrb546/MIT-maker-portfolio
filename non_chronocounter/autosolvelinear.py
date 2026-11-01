import copy # need deepcopy() to avoid changing the original matrices in matrix operations

# find the determinant of a matrix
def det(matrix):
    PDC = copy.deepcopy(matrix)

    # base case
    length = len(matrix)
    if length == 2:
        return delist(matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0])
    if length == 1:
        return delist(matrix[0])
    
    # otherwise use a recursive expansion by minors
    output = 0 
    for i in range(0, length):
        output += matrix[0][i] * det(minor(matrix, (0, i))) * ((-1)**i)
        matrix = copy.deepcopy(PDC)
    return delist(output) # sometimes the output is a list, so delist() is used to convert it to a float

# find and return the inverse of a matrix
def inverse(matrix):
    output = copy.deepcopy(matrix)
    odet = det(matrix) # find the determinant of the original matrix
    for i in range(len(output)):
        for j in range(len(output)):
            output[i][j] = ((-1)**(i+j)) * det(minor(matrix, (i, j)))

    new_output = copy.deepcopy(output)
    for i in range(len(output)):
        for j in range(len(output)):
            new_output[j][i] = output[i][j]/odet
    return new_output

# matrix-vector multiplication
def apply(matrix, vector):
    output = []
    for row in matrix:
        value = 0
        for i in range(len(row)):
            value += row[i] * vector[i]
        output.append(value)
    return output

# find and return the minor of a matrix at a given position
def minor(matrix, position):
    output = copy.deepcopy(matrix)
    output.pop(position[0])
    for i in range(0, len(output)):
        output[i].pop(position[1])
    return output

# convert a list of lists into a float to return a single value (used in det() to avoid returning a list)
def delist(thing):
    while True:
        try:
            float(thing)
            return thing
        except:
            thing = thing[0]


# input section
# input variables
variables = input("please input your variables with one space between each (i.e., a b, x y z) \n").split(" ") # note: potential issue if same variable issued twice

mform = []
constants = []

# main input loop for equations
while True:
    mline = []
    raw = input("please type in an equation with all variables on the left and constants on the right, or 'finish' if you wish to finish entering equations. The constant cannot be negative, and please include a coefficient of -1 if applicable (e.g., write a - 1b = 2 not a - b = 2) \n")
    if raw == "finish":
        break

    # remove spaces in input equation
    line = list(raw)
    for i in range(line.count(" ")):
        line.remove(" ")

    # find the coefficient of each variable in the equation
    for variable in variables:
        value = 0
        if variable in line:
            posicion = line.index(variable)
            for i in range(1, 10000): # arbitrary limit of number of digits in a coefficient
                # read backwards from the variable to find the value of the coefficient
                if posicion - i >= 0 and line[posicion - i].isdigit(): 
                    value += (10**(i-1)) * int(line[posicion - i])
                    #print(line[posicion - i])
                elif line[posicion - i] == "-":
                    value *= -1
                    break
                else: 
                    break
            value = 1 if value == 0 else value # set coefficient to 0 if not present in the equation, or 1 if no coefficient is present
        else: # if it isn't in the equation
            value = 0
        mline.append(value)
    # process the constant
    value = 0
    posicion = len(line)
    for i in range(1, 10000):
            if posicion - i >= 0 and line[posicion - i].isdigit(): 
                value += (10**(i-1)) * int(line[posicion - i])
            else: 
                break
    constants.append(value)
    mform.append(mline)

    # debugging tools
    #print("line: " + str(line))
    #print("mline: " + str(mline))
    #print("constant: " + str(constants))
    #print("mform: " + str(mform))
#"""

"""
variables = ["a", "b", "c"]
mform = [[2, 13, -2], [1, 1, 1], [0, 1,0]]
constants = [22, 6, 2]
#"""
"""
variables = ["a", "b"]
mform = [[5, 5], [5, 0]]
constants = [35,10]
#"""
# solving section
# check for infinite/no answers
if det(mform) == 0 or len(mform) < len(variables):
    print("unfortuantely, there are either no or infinite solutions. Good luck!")
else:
    # main solving
    solution = apply(inverse(mform), constants) # apply the inverse to the constant vectors
    output_str = []
    for i in range(len(solution)):
        output_str.append("{}: {}".format(str(variables[i]), str(solution[i])))
        output_str.append("\n")
    print("solutions: ")
    print("".join(output_str))
