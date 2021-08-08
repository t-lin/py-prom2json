#!/usr/bin/python
import json
import _pyProm2Json

# Read the "prom-out" file, which contains a sample output from a Prometheus Exporter
inputFile = open('prom-out', 'r')
promData = "".join(inputFile.readlines())

# Convert the Prometheus Exporter format to JSON (still in string)
strJson = _pyProm2Json.prom2json(promData)

# Use 'json' to convert the string JSON into actual Python objects
print json.loads(strJson)
