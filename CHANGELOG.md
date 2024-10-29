# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2024-10-29

### Added

- Enable automatic language detection by adding the `-AutoDetectLanguage` switch.
- Add screenshots to the README.

## [1.0.1] - 2024-10-29

### Added

- Initial release of the Transcript Video script.
- Supports video transcription using `whisper-ctranslate2`.
- Handles .mp4, .avi, and .mkv video formats.
- Removes subtitle files with extensions: .json, .tsv, .txt, .vtt.
- Provides a progress bar for tracking file processing.
- Supports optional verbose output for detailed logging.
