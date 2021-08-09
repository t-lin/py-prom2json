import json
import _pyProm2Json

# Read the "prom-out" file, which contains a sample output from a Prometheus Exporter
# The resulting 'promData' is just a long unicode string
inputFile = open('prom-out', 'r')
promData = "".join(inputFile.readlines())
#print promData

# Convert the Prometheus Exporter format to JSON (still in string)
strJson = _pyProm2Json.prom2json(promData)
print(strJson)

# Use 'json' to convert the JSON string into actual Python objects
print("\n\nParsing JSON string")
objects = json.loads(strJson)
print("Parsed %s objects" % len(objects))
print("Sample object: %s" % objects[0])
