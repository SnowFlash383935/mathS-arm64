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

extern void vector_inv_sqrt(float* in, float* out, int n);

static PyObject* method_vector_inv_sqrt(PyObject* self, PyObject* args) {
    Py_buffer in_view, out_view;
    if (!PyArg_ParseTuple(args, "y*y*", &in_view, &out_view)) return NULL;
    int n = in_view.len / sizeof(float);
    vector_inv_sqrt((float*)in_view.buf, (float*)out_view.buf, n);
    PyBuffer_Release(&in_view);
    PyBuffer_Release(&out_view);
    Py_RETURN_NONE;
}

// Объявляем внешнюю функцию из lib.S
extern void vector_sigmoid(float* in, float* out, int n);

static PyObject* method_vector_sigmoid(PyObject* self, PyObject* args) {
    Py_buffer in_view, out_view;

    // Парсим два буфера: входной массив и массив для результата
    if (!PyArg_ParseTuple(args, "y*y*", &in_view, &out_view)) {
        return NULL;
    }

    int n = in_view.len / sizeof(float);
    
    // Вызываем твой мощный ассемблер
    vector_sigmoid((float*)in_view.buf, (float*)out_view.buf, n);

    PyBuffer_Release(&in_view);
    PyBuffer_Release(&out_view);
    
    Py_RETURN_NONE;
}

extern double vector_dot(float* a, float* b, int n);

static PyObject* method_vector_dot(PyObject* self, PyObject* args) {
    Py_buffer a_view, b_view;
    if (!PyArg_ParseTuple(args, "y*y*", &a_view, &b_view)) return NULL;

    int n = a_view.len / sizeof(float);
    double result = vector_dot((float*)a_view.buf, (float*)b_view.buf, n);

    PyBuffer_Release(&a_view);
    PyBuffer_Release(&b_view);

    return PyFloat_FromDouble((double)result);
}

extern void matrix_mul(float* A, float* B, float* C, int M, int N, int K);

static PyObject* method_matrix_mul(PyObject* self, PyObject* args) {
    Py_buffer a_v, b_v, c_v;
    int M, N, K;

    if (!PyArg_ParseTuple(args, "y*y*y*iii", &a_v, &b_v, &c_v, &M, &N, &K))
        return NULL;

    matrix_mul((float*)a_v.buf, (float*)b_v.buf, (float*)c_v.buf, M, N, K);

    PyBuffer_Release(&a_v);
    PyBuffer_Release(&b_v);
    PyBuffer_Release(&c_v);
    Py_RETURN_NONE;
}

static PyMethodDef MathSMethods[] = {
    {"vector_hypot", method_vector_hypot, METH_VARARGS, "Vectorized Pythagoras"},
    {"vector_dot", method_vector_dot, METH_VARARGS, "Vector Dot Product"},
    {"vector_inv_sqrt", method_vector_inv_sqrt, METH_VARARGS, "Fast 1/sqrt(x)"},
    {"matrix_mul", method_matrix_mul, METH_VARARGS, "Matrix Multiplication"},
    {"vector_sigmoid", method_vector_sigmoid, METH_VARARGS, "Fast Vector Sigmoid"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef maths_module = {
    PyModuleDef_HEAD_INIT, "mathS", NULL, -1, MathSMethods
};

PyMODINIT_FUNC PyInit_mathS(void) {
    return PyModule_Create(&maths_module);
}
