## 1.0.21
* Fix bug in `init` command where the default generated output directory was `release` instead of `build/release` to match documentation.

## 1.0.20
* Update README build command example to explicitly include the `--env` flag.

## 1.0.19
* Fix bug in `init` command where the default generated config template incorrectly used the unsupported `{build}` placeholder instead of `{counter}`.

## 1.0.18
* Update README to fix build command syntax to explicitly include the mandatory `-t` target flag.

## 1.0.17
* Rewrite README to simplify documentation and emphasize `dart run` usage over global installation.

## 1.0.16
* Rename executable command and configuration file from `flutter_release` to `flutter_build_manager`.

## 1.0.15
* Update README to reflect new single date folder structure and new `build/release` default path.

## 1.0.14
* Update release directory structure to use a single date format `dd_MM_yyyy` (e.g. `24_07_2026`).
* Simplify configuration to use a single `date` key under `organize_by` instead of separate `year` and `month` keys.
* Move default release directory inside the `build` folder (`build/release`).
