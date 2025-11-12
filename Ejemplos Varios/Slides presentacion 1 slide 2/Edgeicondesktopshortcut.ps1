$Path = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Microsoft Edge.lnk"

# Public desktop path
$destinationpath = [System.IO.Path]::Combine(
    [System.Environment]::GetFolderPath("CommonDesktopDirectory"), 
    $shortcutName
)

# Full path of the shortcut
$sourcePath = [System.IO.Path]::Combine($Path, $shortcutName)

# Create shortcut on the public desktop
Copy-Item -Path $sourcePath -Destination $destinationpath
