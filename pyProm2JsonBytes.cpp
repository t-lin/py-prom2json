/* Copyright 2021 Thomas Lin
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <Python.h>

#include <iostream>
#include <string>

#include "libpyProm2Json.h"

using std::string;
using std::cerr;
using std::endl;

/* ========== HELPER FUNCTIONS ========== */
inline GoString cStr2GoStr(const char* in) {
    GoString tmp = {in, (ptrdiff_t)strlen(in)};
    return tmp;
}

/* Function exposed to Python; wraps the underlying goProm2Json() function from Go
 * Takes one parameter:
 *  - promData: Python string representing the output from a Python Exporter
 */
static PyObject* _PyProm2Json(PyObject *self, PyObject *args, PyObject *keywords) {
    const char *pPromData = NULL;

    static char *kwlist[] = {(char*)"promData", NULL};
    // "s" = const char*
    if (PyArg_ParseTupleAndKeywords(args, keywords, "s", kwlist, &pPromData) && pPromData) {
        char *jsonData = goProm2Json(cStr2GoStr(pPromData));
        PyObject* pyStrJson = PyUnicode_FromStringAndSize(jsonData, (Py_ssize_t )strlen(jsonData));
        free(jsonData); // Free memory allocated by cgo
        return pyStrJson;
    } else {
        cerr << "ERROR: Unable to parse input parameter" << endl;
    }

    Py_RETURN_NONE;
}

static PyMethodDef pyProm2JsonMethods[] = {
    {"prom2json", (PyCFunction)_PyProm2Json, METH_VARARGS | METH_KEYWORDS, "Convert Prometheus exporter output string to JSON string"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

#ifdef PYTHON3
static struct PyModuleDef pyProm2JsonModule = {
    PyModuleDef_HEAD_INIT,
    "pyProm2Json",
    NULL, // No docs
    -1, // Keep state in global vars
    pyProm2JsonMethods
};

// Double-underscore to keep compatibility w/ Python2 version
PyMODINIT_FUNC PyInit__pyProm2Json()
{
    return PyModule_Create(&pyProm2JsonModule);
}
#else
PyMODINIT_FUNC init_pyProm2Json() {
    // Create module and add methods
    Py_InitModule("_pyProm2Json", pyProm2JsonMethods);
}
#endif
