load("@rules_pkg//:pkg.bzl", "pkg_tar")
version = "0.0.1"

exports_files([
    "LICENSE"
])

filegroup(
    name = "distribution",
    srcs = [
        "LICENSE",
        "//rules_python_poetry:distribution"
    ]
)

pkg_tar(
    name = "rules_python_poetry-%s" % version,
    srcs = [
        ":distribution",
    ],
    extension = "tar.gz",
    # It is all source code, so make it read-only.
    mode = "0444",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    package_dir = ".",
    strip_prefix = "./rules_python_poetry",
)