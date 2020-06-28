# Python Poetry Rules for Bazel
These rules are designed to allow you to easily use the [Poetry Package Manager](https://python-poetry.org/) with [Bazel](https://bazel.build/). It does this whilst still allowing you to use Poetry as usual with `poetry add` and `poetry run`.

## Getting started
To illustrate how to use this package, there's an [example project](./example) included which shows all the relevant wiring. 

## Poetry Setup
In order to smoothen out the interactions between Bazel and Poetry, we use the common Python location of `.venv` for the Virtual Environment. This makes it easier for both tools to find it, this is configured using [the `virtualenvs.in-project` configuration with Poetry](https://python-poetry.org/docs/configuration/#virtualenvsin-project-boolean):

```
poetry config virtualenvs.in-project true --local
```

Which results in the [`poetry.toml` file found in our example project](./examples/poetry.toml). You can then use the normal Poetry commands.

## Bazel Setup
To enable Bazel to manage the Poetry Virtual Environment, we use the [`managed_directories` property in our example WORKSPACE](./examples/WORKSPACE); this lets Bazel recreate the environment within our workspace, and symlinks it into the Bazel environment:

```py
workspace(
    name = "basic_project",
    managed_directories = {
        "@poetry_environment": [".venv"]
    }
)
```

Afterwards, we use the `http_archive` package to download the rules:

```py
http_archive(
    name = "rules_python_poetry",
    url = "https://github.com/DaMouse404/rules_python_poetry/releases/download/0.0.1/rules_python_poetry-0.0.1.tar.gz",
    sha256 = "3ac54f1e9b070d2ed727c58f30798f4cea1123242279e7d6e1a48e1f06ca16d6",
)
```

Then we run the `poetry_enviromment` rule from `environment.bzl`, which generates the Virtual Environment if necessary, alongside symlinking the various Poetry configuration files into the Bazel environment:

```py
load("@rules_python_poetry//:environment.bzl", "poetry_environment")
poetry_environment(
    name="poetry_environment",
    project="//:pyproject.toml",
    lock="//:poetry.lock",
    config="//:poetry.toml"
)
```

Then we can register the Poetry Python intrepreter as a toolchain for `PY3` in Bazel:

```py
register_toolchains("@poetry_environment//:poetry_toolchain")
```

And finally we use `poetry export` to export requirements to `requirements.txt` format:

```py
load("@poetry_environment//:runtime.bzl", "interpreter_path")
load("@poetry_environment//:export.bzl", "poetry_export")
poetry_export(
    name="poetry_requirements"
)
```

Which can then be used to interact with [the standard `rules_python`](https://github.com/bazelbuild/rules_python) (take note of the `python_interpreter` passed to `pip_import` here to use the virtual env one):

```py
http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.2/rules_python-0.0.2.tar.gz",
    strip_prefix = "rules_python-0.0.2",
    sha256 = "b5668cde8bb6e3515057ef465a35ad712214962f0b3a314e551204266c7be90c",
)
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()
load("@rules_python//python:pip.bzl", "pip_repositories", "pip_import")
pip_repositories()

pip_import(
    name = "basic_project_pip",
    requirements = "@poetry_requirements//:requirements.txt",
    python_interpreter = interpreter_path
)
load("@basic_project_pip//:requirements.bzl", "pip_install")
pip_install()
```