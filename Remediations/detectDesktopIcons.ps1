function Get-Shortcuts ($shortcut) {
    if ($shortcut.Icon) {
        $icon = Test-Path $shortcut.Icon
        #Write-Host $shortcut.Icon
        }
    if ($shortcut.Path) {
        $path = Test-Path $shortcut.Path
        #Write-Host $shortcut.Path
        }
        

    if (-not $icon -or -not $path) {
        Write-Output "At least one icon or URL missing."
        exit 1 
    }
    
}

$urlShortcuts = @(
    @{Path="C:\Users\Public\Desktop\url1.url"; URL=""; 	Icon="C:\Windows\icons\ico1.ico"},
    @{Path="C:\Users\Public\Desktop\url2.url"; URL=""; 	Icon="C:\Windows\icons\ico2.ico"},
    @{Path="C:\Users\Public\Desktop\url3.url"; URL=""; 	Icon="C:\Windows\icons\ico3.ico"},
    )

$appShortcuts = @(
    @{Path="C:\Users\Public\Desktop\Excel.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"; 	Icon="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"},
    @{Path="C:\Users\Public\Desktop\Word.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"},
    @{Path="C:\Users\Public\Desktop\Outlook.lnk"; Target="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"}
)

foreach ($url in $urlShortcuts) {
    Get-Shortcuts($url)
}
foreach ($app in $appShortcuts) {
    Get-Shortcuts($app)
}

Write-Output "All icons and URLs present."
exit 0
