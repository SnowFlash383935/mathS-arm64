#define PY_SSIZE_T_CLEAN
#include <Python.h>

extern void asm_reverse(char* str);

static PyObject* method_reverse(PyObject* self, PyObject* args) {
    char* str;
    if (!PyArg_ParseTuple(args, "s", &str)) return NULL;

    // Дублируем строку, так как строки в Python неизменяемы
    char* buffer = strdup(str);
    asm_reverse(buffer);
    
    PyObject* result = Py_BuildValue("s", buffer);
    free(buffer);
    return result;
}

static PyMethodDef FastMethods[] = {
    {"reverse", method_reverse, METH_VARARGS, "Reverse a string using ARM64 ASM"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef fastmodule = {
    PyModuleDef_HEAD_INIT, "fast_arm", NULL, -1, FastMethods
};

PyMODINIT_FUNC PyInit_fast_arm(void) {
    return PyModule_Create(&fastmodule);
}
