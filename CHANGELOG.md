<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

None.

## [v2.0.0] - 2023-08-27

### Added

- Implemented unit tests in `test_generate_module.py`.
  - Known Issue: Running tests will create a blank `service_list.json` file.
  - Added additional `pytest.ini` file for configuring test runtime.
  - Updated `requirements-dev.txt` to contain `pytest-cov`.
    - Moved to `pyproject.toml`.
- Bulk update for modules using the `--all` parameter.
- A bunch of TODO markers in the script.
  - Sorry about the half-baked result, but i really want to release the module updates.

### Fixed

- Required renaming of the Github repository link in README file.

### Changed

- Empty `main.tf` and suggest loading submodules on demand.
  - Note: Due to the massive amount of AWS services, using this module multiple in a project time will bloat your hard drive.
- Pregenerate `terraform-doc`s `README.md` file via `cookiecutter`.
- Replace `trimprefix` and `trimsuffix` with the corresponding `startswith` or `endswith` function.
  - Note: Requires Terraform `>= 1.3`

### Removed

- `terragrunt-doc` pre-commit hook no longer required.

## [v1.0.0] - 2022-06-03

### Added

- Initial project setup.
- `.generate/` directory which contains a script to generate new submodules for AWS services using [cookiecutter](https://github.com/cookiecutter/cookiecutter).
- Implemented the following features for the submodules:
  - Filtering of action names
  - Minifying of action names

[Unreleased]: https://github.com/maunzCache/terraform-aws-action-helper/compare/v1.0.0...HEAD
<!-- [1.0.1]: https://github.com/maunzCache/terraform-aws-action-helper/compare/v1.0.0...v1.0.1 -->
[v1.0.0]: https://github.com/maunzCache/terraform-aws-action-helper/releases/tag/v1.0.0
