"""
Poetry Environment Repository

Designed to manage the virtual environment using Poetry and export a further repository to interact with it.
"""

def _symlink_venv(repository_ctx):
    project_dir = repository_ctx.path(repository_ctx.attr.project).dirname
    repository_ctx.symlink(repository_ctx.path(str(project_dir) + "/.venv"), repository_ctx.path(".venv"))

def _symlink_project_files(repository_ctx):
    repository_ctx.symlink(
        repository_ctx.attr.project,
        repository_ctx.path("pyproject.toml")
    )
    repository_ctx.symlink(
        repository_ctx.attr.lock,
        repository_ctx.path("poetry.lock")
    )
    repository_ctx.symlink(
        repository_ctx.attr.config,
        repository_ctx.path("poetry.toml")
    )

def _render_templates(repository_ctx):
    environment_path = str(repository_ctx.path(".venv").dirname)
    venv_path = str(repository_ctx.path(".venv"))

    repository_ctx.template(
        "BUILD",
        Label("@rules_python_poetry//:BUILD.template"),
        substitutions = {
            "{venv}": venv_path
        },
    )
    repository_ctx.template(
        "export.bzl",
        Label("@rules_python_poetry//:export.bzl.template"),
        substitutions = {
            "{poetry}": environment_path
        },
    )
    repository_ctx.template(
        "runtime.bzl",
        Label("@rules_python_poetry//:runtime.bzl.template"),
        substitutions = {
            "{venv}": venv_path
        },
    )

def _poetry_environment_impl(repository_ctx):
    managed_root = repository_ctx.path(repository_ctx.attr.project).dirname
    repository_ctx.execute(
        ["poetry", "install"],
        working_directory=str(managed_root)
    )

    _symlink_venv(repository_ctx)
    _symlink_project_files(repository_ctx)
    _render_templates(repository_ctx)

poetry_environment = repository_rule(
    attrs = {
        "project": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the pyproject.toml file.",
        ),
        "lock": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the poetry.lock file.",
        ),
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The label of the poetry.toml config file.",
        )
    },
    implementation = _poetry_environment_impl
)