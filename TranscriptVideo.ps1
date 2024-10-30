<# 
.SYNOPSIS 
This script processes video files by transcribing them with `whisper-ctranslate2` and removes related subtitle files if they exist.

.DESCRIPTION 
This script takes a directory of video files (MP4, AVI, MKV, MOV) and checks if a subtitle file (.srt) with the same base name exists. 
If no subtitle is found, the script invokes `whisper-ctranslate2` to generate a transcript. 
The script supports progress tracking, optional verbosity through the `-Verbose` parameter, and automatic language detection with the `-AutoDetectLanguage` parameter.

.PARAMETER FolderPath 
(Optional) The path to the folder containing the video files. If not provided, the current directory will be used.

.PARAMETER AutoDetectLanguage 
(Optional) Automatically detect the language of the video instead of using English by default.

.NOTES 
Author: Victor.Woo  
Date: 2024-10-29  
Version: 1.2  

Dependencies:
- Python environment must be installed on your system. 
- Install the `whisper-ctranslate2` Python package using the following command:
  pip install -U whisper-ctranslate2
- For more information, visit the official repository:
  https://github.com/Softcatala/whisper-ctranslate2

.EXAMPLE 
.\TranscriptVideo.ps1 -FolderPath "C:\Videos" 
Processes all video files in the specified directory with default settings (English transcription).

.EXAMPLE 
.\TranscriptVideo.ps1 -FolderPath "C:\Videos" -AutoDetectLanguage 
Processes all video files with automatic language detection.

.EXAMPLE 
.\TranscriptVideo.ps1 -Verbose 
Runs the script with verbose output, showing `whisper-ctranslate2` execution details.
#>

# Define script parameters
param (
    [Parameter(Mandatory = $false)]
    [string]$FolderPath, # Path to the folder containing video files

    [Parameter(Mandatory = $false)]
    [switch]$AutoDetectLanguage  # Enable automatic language detection if specified
)

# Function: Remove subtitle files with specific extensions
function Remove-SubtitleFiles {
    param (
        [Parameter(Mandatory = $true)]
        $VideoFile, # Video file object

        [Parameter(Mandatory = $true)]
        $Extensions  # Array of subtitle file extensions to remove
    )

    # Loop through each extension and attempt to remove matching subtitle files
    foreach ($extension in $Extensions) {
        $fileToDelete = $VideoFile.BaseName + $extension  # Construct full file name
        if (Test-Path $fileToDelete) {
            Remove-Item $fileToDelete  # Remove the file if it exists
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
        # Define the base command
        $command = "whisper-ctranslate2"

        # Start building the arguments array
        $arguments = @("--model", "medium", "--device", "cpu", $VideoFilePath)

        # If AutoDetectLanguage is enabled, don't add a language; otherwise, default to English
        if (-not $AutoDetectLanguage) {
            $arguments += "--language"
            $arguments += "en"
        }

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose")) {
            Write-Verbose "Executing command: $command $($arguments -join ' ')"
            # Run the command with verbose output
            & $command @arguments
        } else {
            Write-Verbose "Executing command: $command $($arguments -join ' ') *>`$null 2>`$null"
            # Run the command silently by redirecting output to $null
            & $command @arguments *>$null 2>$null
        }
    } catch {
        # Display a warning if the transcription fails
        Write-Warning "Failed to transcribe video: $VideoFilePath"
    }
}

#$VerbosePreference = "Continue"

# Determine the folder path to use; default to the current directory if not specified
if (!$PSBoundParameters.ContainsKey('FolderPath') -and $Args.Count -eq 0) {
    $FolderPath = $PWD.Path  # Use the current directory
} elseif ($Args.Count -gt 0) {
    $FolderPath = $Args[0]  # Use the first argument as the folder path
}

# Validate the provided folder path
if ([string]::IsNullOrWhiteSpace($FolderPath)) {
    Write-Error "No folder path provided."  # Error if the path is empty
    exit 1
}

if (-not (Test-Path -Path $FolderPath)) {
    Write-Error "The specified folder path does not exist: $FolderPath"  # Error if the path is invalid
    exit 1
}

# Retrieve all video files from the specified directory (including subdirectories)
$videoFiles = Get-ChildItem -Path $FolderPath -Include *.mp4, *.avi, *.mkv, *.mov -Recurse

# Check if any video files were found
if ($videoFiles.Count -eq 0) {
    Write-Error "No video files found in the specified directory: $FolderPath"
    exit 1
}

# Save the current working directory to restore later
Push-Location
try {
    # Initialize progress tracking variables
    $activity = "Processing video files"  # Title for the progress bar
    $totalCount = $videoFiles.Count  # Total number of video files to process
    $processedCount = 0  # Counter for processed files

    # Process each video file
    foreach ($videoFile in $videoFiles) {
        # Change to the directory where the video file is located
        Set-Location $videoFile.Directory.FullName

        # Update the progress bar
        $processedCount++
        $percentComplete = ($processedCount / $totalCount) * 100  # Calculate progress percentage
        $status = "Processing $($videoFile.Name)"  # Status message for the progress bar
        Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete

        # Remove existing subtitle files with the specified extensions
        Remove-SubtitleFiles -VideoFile $videoFile -Extensions @(".json", ".tsv", ".txt", ".vtt")

        # If no .srt subtitle file exists, invoke video transcription
        if (-not (Test-Path "$($videoFile.BaseName).srt")) {
            Invoke-VideoTranscription -VideoFilePath $videoFile.FullName
        }

        # Remove subtitle files except .srt
        Remove-SubtitleFiles -VideoFile $videoFile -Extensions @(".json", ".tsv", ".txt", ".vtt")

        # Restore the original working directory
        Pop-Location
    }
    Write-Host "Transcription completed successfully."
} catch {
    # Handle any unexpected errors during processing
    Write-Error "An error occurred: $_"
} finally {
    # Clear the progress bar after completion
    Write-Progress -Activity $activity -Completed
}
