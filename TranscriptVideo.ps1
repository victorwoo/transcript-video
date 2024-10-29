<# 
SYNOPSIS 
This script processes video files by transcribing them with `whisper-ctranslate2` and removes related subtitle files if they exist.

DESCRIPTION 
This script takes a directory of video files (MP4, AVI, MKV) and checks if a subtitle file (.srt) with the same base name exists. If no subtitle is found, the script invokes `whisper-ctranslate2` to generate a transcript. 
The script supports progress tracking, optional verbosity through the `-Verbose` parameter, and automatic language detection with the `-AutoDetectLanguage` parameter. 

PARAMETER FolderPath 
(Optional) The path to the folder containing the video files. If not provided, the current directory will be used.

PARAMETER AutoDetectLanguage 
(Optional) Automatically detect the language of the video instead of using English by default.

NOTES 
Author: Victor.Woo  
Date: 2024-10-29  
Version: 1.1  

PREREQUISITES 
- Python environment must be installed on your system. 
- Install the `whisper-ctranslate2` Python package using the following command: 
  pip install -U whisper-ctranslate2 
- For more information, visit the official repository:  
  https://github.com/Softcatala/whisper-ctranslate2 

EXAMPLE 
.\TranscriptVideo.ps1 -FolderPath "C:\Videos" 
Processes all video files in the specified directory with default settings (English transcription). 

EXAMPLE 
.\TranscriptVideo.ps1 -FolderPath "C:\Videos" -AutoDetectLanguage 
Processes all video files with automatic language detection.

EXAMPLE 
.\TranscriptVideo.ps1 -Verbose 
Runs the script with verbose output, showing `whisper-ctranslate2` execution details. 
#>

# Define the script parameters
param (
    [Parameter(Mandatory = $false)]
    [string]$FolderPath,  # Folder path containing video files

    [Parameter(Mandatory = $false)]
    [switch]$AutoDetectLanguage  # Enable automatic language detection
)

# Function: Remove subtitle files with specific extensions
function Remove-SubtitleFiles {
    param (
        [Parameter(Mandatory = $true)]
        $VideoFile,  # Video file object
        [Parameter(Mandatory = $true)]
        $Extensions  # Array of subtitle file extensions to remove
    )

    # Loop through each extension and remove the corresponding subtitle file if it exists
    foreach ($extension in $Extensions) {
        $fileToDelete = $VideoFile.BaseName + $extension
        if (Test-Path $fileToDelete) {
            Remove-Item $fileToDelete
        }
    }
}

# Function: Execute video transcription using whisper-ctranslate2
function Invoke-VideoTranscription {
    param (
        [Parameter(Mandatory = $true)]
        $VideoFilePath  # Path to the video file to transcribe
    )

    try {
        # Construct the base command
        $command = "whisper-ctranslate2 $VideoFilePath --model medium --device cpu"

        # If AutoDetectLanguage is not enabled, add the default language parameter
        if (-not $AutoDetectLanguage) {
            $command += " --language en"
        }

        # Execute the command with or without verbose output
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose")) {
            Invoke-Expression $command
        } else {
            Invoke-Expression "$command *>$null 2>&1"
        }
    } catch {
        # Display a warning if the transcription fails
        Write-Warning "Failed to transcribe video: $VideoFilePath"
    }
}

# Determine the folder path to use
if (!$PSBoundParameters.ContainsKey('FolderPath') -and $Args.Count -eq 0) {
    # Default to the current working directory if no path is provided
    $FolderPath = $PWD.Path
} elseif ($Args.Count -gt 0) {
    # Use the first positional argument as the folder path
    $FolderPath = $Args[0]
}

# Validate the folder path
if ([string]::IsNullOrWhiteSpace($FolderPath)) {
    Write-Error "No folder path provided."
    exit 1
}

if (-not (Test-Path -Path $FolderPath)) {
    Write-Error "The specified folder path does not exist: $FolderPath"
    exit 1
}

# Retrieve all video files from the folder (including subdirectories)
$videoFiles = Get-ChildItem -Path $FolderPath -Include *.mp4, *.avi, *.mkv -Recurse

# Check if any video files were found
if ($videoFiles.Count -eq 0) {
    Write-Error "No video files found in the specified directory: $FolderPath"
    exit 1
}

# Save the current directory location
Push-Location
try {
    # Initialize progress tracking variables
    $activity = "Processing video files"  # Progress bar title
    $totalCount = $videoFiles.Count  # Total number of video files
    $processedCount = 0  # Counter for processed files

    # Loop through each video file
    foreach ($videoFile in $videoFiles) {
        # Change to the directory where the video file is located
        Set-Location $videoFile.Directory.FullName

        # Update the progress bar
        $processedCount++
        $percentComplete = ($processedCount / $totalCount) * 100
        $status = "Processing $($videoFile.Name)"
        Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete

        # Remove existing subtitle files with the specified extensions
        Remove-SubtitleFiles -VideoFile $videoFile -Extensions @(".json", ".tsv", ".txt", ".vtt")

        # If no .srt subtitle file exists, perform video transcription
        if (-not (Test-Path ("$($videoFile.BaseName).srt"))) {
            Invoke-VideoTranscription -VideoFilePath $videoFile.FullName
        }
    }
} catch {
    # Handle any unexpected errors during processing
    Write-Error "An error occurred: $_"
} finally {
    # Restore the original directory location
    Pop-Location

    # Clear the progress bar
    Write-Progress -Activity $activity -Completed
}
