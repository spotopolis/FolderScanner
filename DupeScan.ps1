#--------------------------------------#
#---------Change values below----------#
#--------------------------------------#

# Directory location for script to scan
# Example: $path = "%USERPROFILE%\Videos"
$path = "%USERPROFILE%\Videos"

# File extensions to include in search
# Example: $extensions = @(".avi", ".divx", ".gifv", ".mp4", ".mpeg", ".mkv", ".mov", ".wmv")
$extensions = @(".avi", ".divx", ".gifv", ".mp4", ".mpeg", ".mkv", ".mov", ".wmv")

#--------------------------------------#
#---------Change values above----------#
#--------------------------------------#

# Get all files with the specified extensions
$files = Get-ChildItem -Path $path -Recurse -File

# Initialize progress bar
$totalFiles = $files.Count
$currentFile = 0

# Filter files by the specified extensions and update progress bar
$filteredFiles = foreach ($file in $files) {
    $currentFile++
    $percentComplete = [math]::Round(($currentFile / $totalFiles) * 100)
    Write-Progress -Activity "Scanning directories" -Status "$percentComplete% Complete: $($file.FullName)" -PercentComplete $percentComplete
    if ($extensions -contains $file.Extension) {
        $file
    }
}

# Group files by their parent directory
$groupedFiles = $filteredFiles | Group-Object { $_.DirectoryName }

# Filter groups to only include those with more than one file
$filteredGroups = $groupedFiles | Where-Object { $_.Count -gt 1 }

# Regex pattern to match files with a year in the name
$yearPattern = '\(\d{4}\)'

# Complete progress bar
Write-Progress -Activity "Scanning directories" -Status "Complete" -PercentComplete 100

# Summary
$totalFolders = ($files | Select-Object -ExpandProperty DirectoryName | Sort-Object -Unique).Count
$foldersWithMultipleFiles = $filteredGroups.Count

Write-Output "Processing complete."
Write-Output ""
Write-Output "Total files scanned: $totalFiles"
Write-Output "Total folders scanned: $totalFolders"
Write-Output "Folders with more than one file: $foldersWithMultipleFiles"
Write-Output ""
Write-Output "Names of folders with more than one file:"
Write-Output ""
$filteredGroups | ForEach-Object { Write-Output $_.Name }
Write-Output ""
Write-Output ""

# Path to the file that stores skipped files in the same directory as the script
$skippedFilesPath = Join-Path -Path $PSScriptRoot -ChildPath "skipped_files.txt"

# Load skipped files into an array
$skippedFiles = @()
if (Test-Path $skippedFilesPath) {
    $skippedFiles = Get-Content $skippedFilesPath
}

# Process each group
foreach ($group in $filteredGroups) {
    $filesInGroup = $group.Group
    $filesWithoutYear = $filesInGroup | Where-Object { $_.Name -notmatch $yearPattern }

    foreach ($file in $filesWithoutYear) {
        # Check if the file was previously skipped
        if ($skippedFiles -contains $file.FullName) {
            Write-Output "Previously skipped: $($file.FullName)"
            continue
        }

        $filesInGroup | ForEach-Object { Write-Output $_.Name }
        Write-Output ""
        $confirmation = Read-Host "Do you want to delete $($file.FullName)? (y/n)"
        if ($confirmation -eq 'y') {
            Remove-Item -Path $file.FullName -Force
            Write-Output "Deleted: $($file.FullName)"
            Write-Output ""
        } else {
            Write-Output "Skipped: $($file.FullName)"
            Write-Output ""
            # Add the skipped file to the text file
            Add-Content -Path $skippedFilesPath -Value $file.FullName
        }
    }
}

pause