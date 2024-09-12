#--------------------------------------#
#---------Change values below----------#
#--------------------------------------#

# Directory location for script to scan
# Example: $path = "%USERPROFILE%\Videos"
$path = ""

# File extensions to include in search
# Example: $extensions = @(".avi", ".divx", ".gifv", ".mp4", ".mpeg", ".mkv", ".mov", ".wmv")
$extensions = @()

#--------------------------------------#
#---------Change values above----------#
#--------------------------------------#

# Save the current console color
$originalColor = $Host.UI.RawUI.ForegroundColor

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

Write-Output "***************************************************************************"
Write-Output ""
Write-Output "Processing complete."
Write-Output ""
Write-Output "Total files scanned: $totalFiles"
Write-Output "Total folders scanned: $totalFolders"
$Host.UI.RawUI.ForegroundColor = "Red"
Write-Output "Total file conflicts to resolve (includes previously skipped files): $foldersWithMultipleFiles"
$Host.UI.RawUI.ForegroundColor = $originalColor
Write-Output ""
Write-Output "***************************************************************************"
Write-Output ""
Write-Output "Names of folders with more than one file:"
Write-Output ""
$filteredGroups | ForEach-Object { Write-Output $_.Name }
Write-Output ""

# Collect all files to be deleted
$filesToDelete = @()

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
			$Host.UI.RawUI.ForegroundColor = "Yellow"
            Write-Output "Previously skipped: $($file.FullName)"
			$Host.UI.RawUI.ForegroundColor = $originalColor
            continue
		}
        $filesToDelete += $file
    }
}

Write-Output ""
Write-Output "***************************************************************************"
Write-Output ""

# Check if there are files to be deleted
if ($filesToDelete.Count -eq 0) {	
    # Clear the progress bar
    Write-Progress -Activity "Scanning directories" -Status "Complete" -Completed
	Write-Output "No files to be deleted."	
    if ($skippedFiles.Count -gt 0) {
		$Host.UI.RawUI.ForegroundColor = "Yellow"
        Write-Output "Previously skipped files:"
		Write-Output ""
        $skippedFiles | ForEach-Object { Write-Output $_ }
		$Host.UI.RawUI.ForegroundColor = $originalColor
    }
	Write-Output ""
	Write-Output ""
    Write-Host "Press any key to close this window..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Display all files to be deleted
$Host.UI.RawUI.ForegroundColor = "Red"
Write-Output "The following files will be deleted:"
$Host.UI.RawUI.ForegroundColor = $originalColor
$filesToDelete | ForEach-Object { Write-Output $_.FullName }
Write-Output ""

# Display files with year in the name for comparison
$Host.UI.RawUI.ForegroundColor = "Green"
Write-Output "Files to be kept:"
$Host.UI.RawUI.ForegroundColor = $originalColor
$filesWithYear = $filteredFiles | Where-Object { $_.Name -match $yearPattern }
$filesWithYear | ForEach-Object { Write-Output $_.FullName }
Write-Output ""

# Initialize counters for summary
$deletedFilesCount = 0
$totalSpaceRegained = 0

# Prompt the user for confirmation
$confirmation = Read-Host "Do you want to delete all these files? (y/n) (Default 'Yes')"
if ($confirmation -eq 'y' -or $confirmation -eq '') {
    $filesToDelete | ForEach-Object {
        $fileSize = $_.Length
        Remove-Item -Path $_.FullName -Force
        Write-Output "Deleted: $($_.FullName)"
        $deletedFilesCount++
        $totalSpaceRegained += $fileSize
    }
} else {
    # Continue with one-by-one comparison
    foreach ($file in $filesToDelete) {
        $confirmation = Read-Host "Do you want to delete $($file.FullName)? (y/n) (Default 'Yes')"
        if ($confirmation -eq 'y' -or $confirmation -eq '') {
			$fileSize = $file.Length
            Remove-Item -Path $file.FullName -Force
            Write-Output "Deleted: $($file.FullName)"
			$deletedFilesCount++
            $totalSpaceRegained += $fileSize
			Write-Output ""
        } else {
            Write-Output "Skipped: $($file.FullName)"
			Write-Output ""
			# Add the skipped file to the text file
            Add-Content -Path $skippedFilesPath -Value $file.FullName
        }
    }
}

# Convert total space regained to gigabytes
$totalSpaceRegainedGB = [math]::Round($totalSpaceRegained / 1GB, 2)

# Display summary
Write-Output ""
Write-Output "Summary:"
Write-Output "Total files deleted: $deletedFilesCount"
Write-Output "Total space regained: $totalSpaceRegainedGB GB"
Write-Output ""
Write-Output ""

Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
