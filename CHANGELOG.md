<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Implemented unit tests in `test_generate_module.py`.
  - Added additional `pytest.ini` file for configuring test runtime.
  - Updated `requirements-dev.txt` to contain `pytest-cov`.

## [v1.0.0] - 2022-06-03

### Added

- Initial project setup.
- `.generate/` directory which contains a script to generate new submodules for AWS services using [cookiecutter](https://github.com/cookiecutter/cookiecutter).
- Implemented the following features for the submodules:
  - Filtering of action names
  - Minifying of action names

[Unreleased]: https://github.com/maunzCache/aws-action-helper/compare/v1.0.0...HEAD
<!-- [1.0.1]: https://github.com/maunzCache/aws-action-helper/compare/v1.0.0...v1.0.1 -->
[v1.0.0]: https://github.com/maunzCache/aws-action-helper/releases/tag/v1.0.0
