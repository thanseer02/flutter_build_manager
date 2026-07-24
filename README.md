# flutter_build_manager

[![pub package](https://img.shields.io/pub/v/flutter_build_manager.svg)](https://pub.dev/packages/flutter_build_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A production-ready Flutter Release Manager that automatically builds, renames, organizes, and tracks your Flutter release artifacts (APK, AAB, IPA) natively.

## Why use flutter_build_manager?

Managing Flutter releases manually is tedious and messy. Developers often struggle with forgetting to bump version numbers, losing track of which APK was sent to QA, and overwriting previous builds.

**`flutter_build_manager` solves this by:**
✅ Automatically naming your files (e.g., `MyApp_20260724_LIVE_001.apk`)
✅ Organizing outputs into clean date-based folders (`build/release/24_07_2026/`)
✅ Keeping a smart build counter (`001`, `002`) so files never overwrite
✅ Generating SHA256 checksums and `release.json` metadata for CI/CD

---

## 🚀 Installation

We highly recommend installing this directly into your project's `dev_dependencies` so you don't have to worry about global system `$PATH` issues.

Run this command in your Flutter project:
```bash
flutter pub add dev:flutter_build_manager
```

---

## 🛠 Quick Start (How to use it)

If you installed it in your project as recommended, you can run it using the `dart run` command.

*(Note: If you use FVM, simply add `fvm` to the beginning of these commands, like `fvm dart run flutter_build_manager init`)*

### 1. Initialize the configuration
Run this once to create your `flutter_build_manager.yaml` config file:
```bash
dart run flutter_build_manager init
```

### 2. Preview your build (Optional)
Want to see what the filename and folder will look like without actually taking the time to compile?
```bash
dart run flutter_build_manager preview
```

### 3. Build your release!
Ready to compile? Run the build command for your target (`apk`, `aab`, or `ipa`):
```bash
dart run flutter_build_manager build -t apk --env=LIVE
```

---

## 📁 Where do my files go?

When you execute a build, the manager safely isolates its outputs so they never clash with Flutter's messy default build folder:

```text
my_app/
  ├── build/
  │    └── release/             <-- All releases go here
  │         └── 24_07_2026/     <-- Organized by today's date
  │              └── LIVE/      <-- Grouped by environment
  │                   ├── MyApp_20260724_LIVE_001.apk
  │                   ├── MyApp_20260724_LIVE_001.apk.sha256
  │                   └── release.json
```

---

## ⚙️ Configuration

When you run the `init` command, it generates a simple `flutter_build_manager.yaml` file in your project. You can edit this file to change how your files are named and organized:

```yaml
release_manager:
  enabled: true
  output_directory: build/release
  template: "{project}_{date}_{env}_{counter}"
  build_counter:
    mode: daily
  organize_by:
    date: true
    environment: true
```

### Filename Templates
Customize your artifact filenames using dynamic placeholders inside your `template` string.

- `{project}` - Project name
- `{version}` - e.g., 1.0.0
- `{date}` - e.g., 20260724
- `{env}` - e.g., LIVE, DEV, QA
- `{counter}` - e.g., 001

---

## 🤝 Contributing
Contributions are always welcome! Feel free to open an issue or pull request on our GitHub repository.

## 📝 License
This project is licensed under the MIT License.
