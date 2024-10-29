<# 
.SYNOPSIS 
This script recursively deletes specific subtitle files from the specified directories.

.DESCRIPTION 
This script accepts one or more folder paths and removes files with the extensions:
- .json
- .srt
- .tsv
- .txt
- .vtt

If no folder path is provided, it defaults to the current directory. The script can handle multiple paths and provides optional verbosity for detailed logging.

.PARAMETER FolderPaths 
(Optional) One or more folder paths to clean. If not specified, the current directory will be used.

.NOTES 
Author: Victor.Woo  
Date: 2024-10-29  
Version: 1.0  

.EXAMPLE 
.\RemoveSubtitles.ps1 -FolderPaths "C:\Videos", "D:\Movies"
Deletes specific subtitle files from both "C:\Videos" and "D:\Movies".

.EXAMPLE 
.\RemoveSubtitles.ps1 -Verbose
Deletes specific subtitle files from the current directory with detailed output.
#>

# Define the script parameters
param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string[]]$FolderPaths  # Accept one or more folder paths
)

# Define the file extensions to remove
$Extensions = @(".json", ".srt", ".tsv", ".txt", ".vtt")

# Function: Remove subtitle files with specific extensions
function Remove-SubtitleFiles {
    param (
        [Parameter(Mandatory = $true)] [string]$TargetDirectory
    )

    if (-not (Test-Path $TargetDirectory)) {
        Write-Host "Directory not found: $TargetDirectory" -ForegroundColor Red
        return
    }

    foreach ($extension in $Extensions) {
        # Retrieve and delete files with the specified extension
        Get-ChildItem -Path $TargetDirectory -Recurse -Filter "*$extension" | ForEach-Object {
            try {
                Remove-Item $_.FullName -Force
                Write-Verbose "Deleted: $($_.FullName)"
            } catch {
                Write-Warning "Failed to delete: $($_.FullName) - $_"
            }
        }
    }
}

# Main script logic
if (-not $FolderPaths) {
    # Default to the current directory if no paths are specified
    $FolderPaths = @($PWD.Path)
}

# Process each folder path provided
foreach ($folder in $FolderPaths) {
    Write-Host "Processing directory: $folder" -ForegroundColor Yellow
    Remove-SubtitleFiles -TargetDirectory $folder
}

Write-Host "Cleanup completed." -ForegroundColor Cyan
