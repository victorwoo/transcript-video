# Transcript Video Script

A [PowerShell](https://learn.microsoft.com/en-us/powershell/) script that automatically generates `.srt` subtitles in bulk for video files using `whisper-ctranslate2`.

![Banner](./Images/Banner.png)

## Features

- **Video Transcription**: Supports .mp4, .avi, mkv, and .mov formats.
- **Subtitle Management**: Removes existing subtitle files with .json, .tsv, .txt, or .vtt extensions.
- **Progress Tracking**: Provides a progress bar to monitor the process.
- **Verbose Mode**: Display detailed execution information when `-Verbose` is used.

## Screen Shots

Running the script:

![running script](./Images/Screen%20shot%20-%20001.png)

The video has been subtitled and is displayed correctly in the player:

![subtitled video](./Images/Screen%20shot%20-%20002.png)

## Prerequisites

- [Python](https://www.python.org/) environment must be installed on your system.
- Install the `whisper-ctranslate2` Python package using the following command:

```powershell
pip install -U whisper-ctranslate2
```

- For more information, visit the official repository:  
  <https://github.com/Softcatala/whisper-ctranslate2>

## Usage

### Basic Usage

To process all video files in the current directory:

```powershell
PS> .\TranscriptVideo.ps1
```

### Process a Specific Folder

To specify the folder containing video files:

```powershell
PS> .\TranscriptVideo.ps1 -FolderPath "C:\Videos"
```

### Enable Verbose Mode

To display detailed output:

```powershell
PS> .\TranscriptVideo.ps1 -Verbose
```

## Parameters

- **FolderPath**: (Optional) The path to the folder containing video files. If not provided, the current directory will be used.

## Example

```powershell
PS> .\TranscriptVideo.ps1 -FolderPath "C:\Videos" -Verbose
```

Processes all video files in C:\Videos with detailed output enabled.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

- [Victor Woo](https://github.com/victorwoo)
