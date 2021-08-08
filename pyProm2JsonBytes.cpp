#include <Python.h>

#include <iostream>
//#include <cstring>
//#include <cstdlib>
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
        PyObject* pyStrJson = PyString_FromStringAndSize(jsonData, (Py_ssize_t )strlen(jsonData));
        free(jsonData); // Free memory allocated by cgo
        return pyStrJson;
    } else {
        cerr << "ERROR: Unable to parse input parameter" << endl;
    }

    Py_RETURN_NONE;
}

static PyMethodDef pyProm2JsonMethods[] = {
    {"prom2json", (PyCFunction)_PyProm2Json, METH_KEYWORDS, "Convert Prometheus exporter output string to JSON string"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

PyMODINIT_FUNC init_pyProm2Json() {
    // Create module and add methods
    Py_InitModule("_pyProm2Json", pyProm2JsonMethods);
}
