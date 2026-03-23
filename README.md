# FreeType Whisper Studio

FreeType Whisper Studio is a Flutter desktop app for Windows and Linux that turns local speech into text with a Whisper-compatible runtime on your own machine.

## Features

- Rounded modern desktop UI
- Chinese and English interface
- Light, dark, and system theme modes
- Live dictation workflow for microphone input
- Local model library with size filtering
- Built-in reminder before downloading Whisper models
- Configurable model storage directory
- Video import with audio extraction through FFmpeg
- Markdown transcript export

## Runtime Design

The Flutter app does not send audio to any cloud service.

It calls local command-line tools that you configure:

- A local Whisper-compatible executable
  Suggested: a GPU-enabled `whisper.cpp` build for Windows or Linux
- A local `ffmpeg` executable for video audio extraction
- A local Whisper model file such as `ggml-small.bin`

## Quick Start

1. Open the app.
2. Set the Whisper executable path.
3. Set the FFmpeg executable path.
4. Choose a model directory.
5. Download a model from the built-in model list, or place an existing model in the model directory and select it.
6. Start live dictation or import a video file.

## Model Download Reminder

When you click download inside the app, the UI shows a confirmation reminder before fetching the model so you can check network access and disk space first.

## GPU Notes

GPU acceleration depends on the Whisper runtime you choose. The app itself is a local desktop shell and will use whatever backend your local Whisper executable already supports, such as Vulkan, CUDA, or OpenCL in a compatible build.

## Local Verification

Verified locally on this machine:

- `flutter analyze`
- `flutter test`
- `flutter build windows`

Linux desktop files were generated and the app code targets Linux, but Linux build verification was not run in this Windows environment.

## License

This project uses the MIT License to stay aligned with the Whisper project family and common Whisper-compatible runtimes such as `whisper.cpp`.

Important: MIT is fully open source and allows commercial use. A "non-commercial but consistent with Whisper" license is not possible because Whisper's license does not include a non-commercial restriction.
