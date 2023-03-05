import json
from types import SimpleNamespace
import code
import sys
import subprocess

python_dir = "python3"
file_dir = "./userCode.py"
test_dir = sys.argv[1]

text = ''
with open(test_dir, 'r') as file:
    text = file.read()

testData = json.loads(text, object_hook=lambda x: SimpleNamespace(**x))
testCases = testData.cases

results = {"testResults": []}
returnResults = []
stdoutResults = []

for case in testCases:
    returned, stdout = None, None
    returnPassed, stdoutPassed = True, True
    if testData.data.useFunction:
        userSolution = getattr(code, testData.data.functionName)
        returned = userSolution(*case.input)
        returnPassed = (not testData.data.useFunction) or (returned == case.returns)
        returnResults.append((returnPassed, returned))
    else:
        returnResults.append((True, None))

    programOutput = subprocess.run([python_dir, file_dir], capture_output=True)
    stdout = programOutput.stdout.decode('utf-8')
    stderr = programOutput.stderr.decode('utf-8')
    stdoutPassed = (not testData.data.usestdout) or (stdout == case.stdout)
    stdoutResults.append((stdoutPassed, returned))

    totalResult = {
        "input": case.input,
        "returns": case.returns,
        "stdout": case.stdout,
        "userReturned": returned,
        "userstdout": stdout,
        "passed": returnPassed and stdoutPassed,
        "error": stderr
    }
    results['testResults'].append(totalResult)

resultJSON = json.dumps(results, indent=4)

with open('./results.json', 'w') as file:
    file.write(resultJSON)

