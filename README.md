
# Python Library for Simple prom2json Conversion
A very basic library to expose the prom2json conversion functionality in Python (direct string-to-string conversion).
The resulting JSON-formatted string can then be loaded via the Python `json` library into a Python dictionary for direct data manipulation.

Under-the-hood, this library uses a stripped down version of the Go prom2json, compiles it into a C/C++ library, which is then wrapped in a Python C/C++ extension module.

**Tested in Ubuntu 20.04; built with g++ 9.3.0 and golang 1.13.15 on x86-64 CPU; and tested with Python2.7.18 and Python3.8.10.**

## Compiling & Installing
By default, the compilation is intended for Python2.7.
Simply run `make` to compile and build the Go library into a C/C++ static library archive with the accompanying header file, which is then used by the Python extension module into a Python-useable library (the resulting \*.so file).
To compile for Python3 (versions 3.5 to 3.8), simply run `make PYVERS=3`.
By default, only Python code in the same directory as the \*.so file can use it.

After compiling, run the `test.py` file to verify everything works.
The `test.py` script should read the contents of `prom-out` and convert it to a JSON string, which is verified via the `json` package.

To make the library accessible to other programs, run `make install` (or `make PYVERS=3 install` if installing for Python3) to put the library in the globally-accessible Python PATH.

## Why does this exist?
I needed a library that can give me a straight Python dictionary. That's it. Simple.

If more robust work is needed, use the `text_string_to_metric_families()` function of the `prometheus_client` library (see: https://www.robustperception.io/productive-prometheus-python-parsing), which converts the metrics into Python objects for OOP.

