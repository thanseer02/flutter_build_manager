# Release Manager Example

This is a production-quality example application for the `flutter_build_manager` package. It serves as both documentation and an integration test bed.

## Project Structure

- **`lib/main.dart`**: Contains a minimal UI demonstrating the application identity.
- **`pubspec.yaml`**: Configured to depend locally on `flutter_build_manager` using `path: ../`.
- **`flutter_release.yaml`**: The configuration file driving the release manager behavior.
- **`test_release.sh`**: An automated shell script to execute a full integration test.

## Configuration Details

The `flutter_release.yaml` is configured with:
- `project_name`: "Release Manager Example"
- `output_directory`: ".build_release"
- `filename_template`: `{project}_{version}_{env}_{counter}`
- Features enabled: Daily counter reset, Git Metadata generation, Checksum (SHA256), and FVM integration.

### Generated Release Folder
Upon a successful build, the release artifacts will be placed in the `.build_release` directory, formatted as configured.

### Environment & Counter Behavior
- Default environment is set to `DEV`. 
- Counters are tracked in `.build_release/.build_counter.json` and reset daily automatically.

## How to use

### 1. Navigate into example
```bash
cd example
```

### 2. Install packages
```bash
fvm flutter pub get
```

### 3. Initialize
```bash
fvm dart run flutter_build_manager:flutter_release init
```
*Expected output: Informs you that the project is already initialized or creates the base configuration.*

### 4. Verify
```bash
fvm dart run flutter_build_manager:flutter_release doctor
```
*Expected output: Checks for FVM, Flutter installation, and ensures environment is valid.*

### 5. Preview filename
```bash
fvm dart run flutter_build_manager:flutter_release preview
```
*Expected output: Prints out the projected configuration (Version, Env, Counter) and the projected filename like `Release_Manager_Example_1.0.0+1_DEV_001.apk`.*

### 6. Build APK
```bash
fvm dart run flutter_build_manager:flutter_release build --target apk
```
*Expected output: Compiles the APK, renames it based on the template, moves it into `.build_release`, generates metadata, and generates the SHA256 checksum.*

### 7. Build AAB
```bash
fvm dart run flutter_build_manager:flutter_release build --target aab
```
*Expected output: Same as APK, but generates an Android App Bundle.*

### 8. Build IPA
```bash
fvm dart run flutter_build_manager:flutter_release build --target ipa
```
*Expected output: Same as above, but for iOS (Requires macOS).*

## Automated Integration Test
You can run the full automated verification test by running:
```bash
./test_release.sh
```

## Troubleshooting & Common Errors
- **Command not found (dart)**: Ensure you prepend `fvm` if using FVM.
- **Pubspec errors**: Ensure `flutter_build_manager` is referenced correctly in dependencies using `path: ../`.
- **Build failures**: Ensure standard Flutter build commands succeed independently (`fvm flutter build --target apk`).
