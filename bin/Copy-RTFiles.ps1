#
# PowerShell Script for RT Documents and DICOM file copy
#

#
# PowerShell Trigger check
#

$PSTRIGGER="D:\RT-DRm-Cache\__PSTRIGGER__"
if (!(Test-Path $PSTRIGGER))
{
	Write-Output "PowerShell NOT to be Triggered for now!"
	exit
}

# Remove the trigger file to avoid another schedule task starting before the current one stops
Remove-Item -Path $PSTRIGGER -Recurse -Force


$docListFile="doc_file_list.txt"
$dcmListFile="dcm_path_list.txt"
$workFolder="D:\RT-DRm-Cache"

$DTTAG=(Get-Date -Format FileDateTime).Substring(0,13)
# $DTTAG 2>&1 | Tee-Object -FilePath "$workFolder\RT-Copy-$DTTAG.log" 


#
# Document files
#

if (!(Test-Path (Join-Path $workFolder $docListFile)))
{
    Write-Output "Doc File List not Found!"
    exit
}

foreach($srcFile in Get-Content $docListFile)
{
    $dstFolder=Join-Path $workFolder 'Documents'
    if (!(Test-Path $dstFolder -PathType Container))
    {
        New-Item -Path $dstFolder -ItemType Directory -Force
    }
    Copy-Item -Path $srcFile -Destination $dstFolder -Force 2>&1 | 
        Tee-Object -FilePath "$workFolder\RT-Copy-$DTTAG.log" -Append
    Write-Output "Copied $srcFile"
}

Write-Output "Done with Doc file copy!"


#
# DICOM Files
#

if (!(Test-Path (Join-Path $workFolder $dcmListFile)))
{
    Write-Output "DICOM Folder List File not Found!"
    exit
}

foreach($srcFolder in Get-Content $dcmListFile)
{
    $dcmFolder=Join-Path $srcFolder 'DICOM'
    $ptPathId=Split-Path $srcFolder -Leaf
    $dstFolder=Join-Path (Join-Path $workFolder "DICOM") $ptPathId
    if (!(Test-Path $dstFolder -PathType Container))
    {
        New-Item -Path $dstFolder -ItemType Directory -Force
    }
    Write-Output "Copy-Item -Path $dcmFolder -Destination $dstFolder -Recurse -Force"
    #Copy-Item -Path $dcmFolder -Destination $dstFolder -Recurse 
    Copy-Item -Path (Get-Item -Path "$dcmFolder\*" -Exclude ('Image')).FullName -Destination $dstFolder -Recurse -Force 2>&1 |
        Tee-Object -FilePath "$workFolder\RT-Copy-$DTTAG.log" -Append
    #Write-Output "Copied $srcFolder"
}


#
# Archive the folders for data transfer
#

Remove-Item -Path $workFolder\*.zip -Recurse -Force

Compress-Archive -Path $workFolder\Documents -DestinationPath $workFolder\documents.zip
Compress-Archive -Path $workFolder\DICOM -DestinationPath $workFolder\dicom.zip

Remove-Item -Path $workFolder\Documents -Recurse -Force
Remove-Item -Path $workFolder\DICOM -Recurse -Force
Remove-Item -Path $workFolder\$docListFile -Recurse -Force
Remove-Item -Path $workFolder\$dcmListFile -Recurse -Force

