# FreeType Whisper Studio

FreeType Whisper Studio is a local-first Flutter desktop app for Windows and Linux. It uses your own Whisper-compatible runtime and FFmpeg binaries to turn speech or video audio into text and Markdown notes without sending audio to a cloud service.

## Highlights

- Rounded desktop UI with Chinese and English support
- Light, dark, and system theme modes
- Continuous live dictation with incremental, sentence-final, and whole-transcript paste modes
- Global hotkeys for dictation toggle and paste
- Local Whisper model library with size filters and download reminders
- Whisper runtime tuning with extra CLI arguments
- Guided Whisper and FFmpeg setup with auto-locate, download shortcuts, and CPU/GPU runtime checks
- Video import, FFmpeg audio extraction, local transcription, and Markdown export
- Windows build, Linux bundle, `.deb`, and `.rpm` packaging

## Runtime Model

The app is only a local desktop shell. You provide:

- A local Whisper-compatible executable
  Recommended: a GPU-enabled `whisper.cpp` build
- A local `ffmpeg` executable
- A local Whisper model file such as `ggml-small.bin`

The app then orchestrates setup, recording, model downloads, dictation, transcription, and export on your machine.

## Dependencies

### Runtime dependencies

- Whisper-compatible CLI
  Suggested: [`whisper.cpp`](https://github.com/ggml-org/whisper.cpp)
- FFmpeg
  Suggested: [ffmpeg.org](https://ffmpeg.org/download.html)
- A local Whisper model file

### Flutter dependencies

Main packages used by the app:

- `file_picker`
- `hotkey_manager`
- `path_provider`
- `record`
- `shared_preferences`

### Linux packaging dependencies

Used during Linux packaging and verification:

- `cpack`
- `dpkg-deb`
- `rpm` / `rpmbuild`
- `keybinder-3.0`

## Supported Environments

### Application targets

- Windows desktop
- Linux desktop

### Verified build environments

- Windows with Flutter desktop toolchain
- WSL2 Ubuntu 24.04 for Linux builds and package generation

### Runtime compatibility notes

- GPU acceleration depends on the Whisper binary you choose.
- The app can detect likely backend hints such as CUDA, Vulkan, OpenCL, Metal, or CoreML only if they appear in the runtime help output.
- On Linux, auto paste requires `xdotool`.

## Quick Start

1. Launch the app.
2. Configure the Whisper executable path.
3. Configure the FFmpeg executable path.
4. Choose a model directory.
5. Download a model from the built-in library or place an existing model in the model directory.
6. Select the model file in the app.
7. Run the CPU/GPU runtime test if you want to verify the current backend.
8. Start live dictation or import a video.

## Packaging Outputs

Release artifacts produced locally for `v1.0.0`:

- Windows executable: `build/windows/x64/runner/Release/freetype.exe`
- Linux bundle executable: `build/linux/x64/release/bundle/opt/freetype/freetype`
- Linux Debian package: `build/linux/x64/release/freetype-whisper-studio_1.0.0_amd64.deb`
- Linux RPM package: `build/linux/x64/release/freetype-whisper-studio-1.0.0-1.x86_64.rpm`

## Local Verification

Verified locally on this machine:

- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `flutter build linux`
- `cpack -G DEB`
- `cpack -G RPM`

## License

This project uses the MIT License to stay aligned with the Whisper project family and common Whisper-compatible runtimes such as `whisper.cpp`.

Important: MIT is fully open source and allows commercial use. A "non-commercial but consistent with Whisper" license is not possible because Whisper's license does not include a non-commercial restriction.
