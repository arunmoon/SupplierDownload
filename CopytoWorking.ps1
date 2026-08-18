# Source folder
$sourceFolder = "C:\Users\aknmo\Downloads"

# Destination file
$destinationFile = "C:\Users\aknmo\OneDrive\Desktop\Arun\EMEasy Workspace\working.xml"

# Find the latest XML file
$latestFile = Get-ChildItem -Path $sourceFolder -Filter *.xml |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1

if ($latestFile) {
    Copy-Item -Path $latestFile.FullName -Destination $destinationFile -Force
    Write-Host "Copied $($latestFile.Name) to working.xml"
}
else {
    Write-Host "No XML files found in $sourceFolder"
}