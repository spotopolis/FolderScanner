PowerShell Script: Directory File Scanner

Description:

  This PowerShell script scans a specified directory and its subdirectories for files with certain extensions. It provides a progress bar during the scan, groups the files by their parent directories, and identifies directories containing more than one file. The script also allows for the deletion of files that do not match a specific naming pattern (files without a year in their name) and keeps track of skipped files.

Features:

  Directory Scanning: Recursively scans the specified directory for files with the given extensions.
  Progress Bar: Displays a progress bar indicating the scan’s progress.
  File Grouping: Groups files by their parent directories.
  Directory Filtering: Identifies directories containing more than one file.
  File Deletion: Prompts the user to delete files that do not match a specific naming pattern.
  Skipped Files Tracking: Keeps track of files that were skipped during the deletion process.

Usage:

  1.) Set the Directory Path: Modify the  "$path" variable to specify the directory you want to scan.
  
    $path = "%USERPROVILE%\Videos"

  2.) Specify File Extensions: Update the "$extensions" array with the file extensions you want to include in the search.

    $extensions = @(".avi", ".divx", ".gifv", ".mp4", ".mpeg", ".mkv", ".mov", ".wmv")

  3.) Run the Script: Execute the script in PowerShell. The script will:
        Scan the directory and subdirectories for files with the specified extensions.
        Display a progress bar during the scan.
        Group the files by their parent directories.
        Identify directories containing more than one file.
        Prompt the user to delete files that do not match the naming pattern (files without a year in their name).
        Track skipped files in a text file (skipped_files.txt) located in the same directory as the script.

  4.) Review the Output: The script will output a summary of the scan, including the total number of files and directories scanned, and the names of directories containing more than one file.

  Example Output:

    Processing complete.

    Total files scanned: 100
    Total folders scanned: 20
    Folders with more than one file: 5

    Names of folders with more than one file:
    C:\Users\USERPROFILE\Videos\Folder1
    C:\Users\USERPROFILE\Videos\Folder2
    ...

    Previously skipped: C:\Users\USERPROFILE\Videos\Folder1\File1.avi
    Do you want to delete C:\Users\USERPROFILE\Videos\Folder1\File2.avi? (y/n)

Notes
Ensure you have the necessary permissions to delete files in the specified directory.
The script pauses at the end to allow you to review the output.
