load("@rules_python//python:defs.bzl", "py_binary")
load("@basic_project_pip//:requirements.bzl", "requirement")

py_binary(
    name = 'main',
    main = 'main.py',
    srcs = ['main.py'],
    deps = [
        requirement('six')
    ],
    python_version = 'PY3'
)