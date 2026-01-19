# PNG to WebP Converter

[繁體中文](README_zh-TW.md)

A macOS desktop app to convert PNG images to WebP format with drag & drop support.

## Features

- Drag & drop PNG files to convert
- Adjustable output quality (0-100)
- Output file saved to the same location as input
- Shows conversion results: file size comparison, compression ratio
- Supports light/dark mode
- English and Traditional Chinese interface

## Requirements

- macOS
- Flutter SDK
- cwebp (install via Homebrew)

```bash
brew install webp
```

## Run

```bash
flutter run -d macos
```

## Build

```bash
flutter build macos
```

The built app is located at `build/macos/Build/Products/Release/png2webp_app.app`

## License

MIT License
