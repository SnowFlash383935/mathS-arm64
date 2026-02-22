#include <Python.h>

extern void vector_hypot(float* a, float* b, float* out, int n);

static PyObject* method_vector_hypot(PyObject* self, PyObject* args) {
    Py_buffer a_view, b_view, out_view;
    
    // Принимаем три буфера (A, B и выходной массив)
    if (!PyArg_ParseTuple(args, "y*y*y*", &a_view, &b_view, &out_view)) {
        return NULL;
    }

    int n = a_view.len / sizeof(float);
    
    // Вызываем наш ассемблер
    vector_hypot((float*)a_view.buf, (float*)b_view.buf, (float*)out_view.buf, n);

    PyBuffer_Release(&a_view);
    PyBuffer_Release(&b_view);
    PyBuffer_Release(&out_view);
    
    Py_RETURN_NONE;
}

static PyMethodDef MathSMethods[] = {
    {"vector_hypot", method_vector_hypot, METH_VARARGS, "Vectorized Pythagoras"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef maths_module = {
    PyModuleDef_HEAD_INIT, "mathS", NULL, -1, MathSMethods
};

PyMODINIT_FUNC PyInit_mathS(void) {
    return PyModule_Create(&maths_module);
}
