# =========================
# Java 21 + JavaFX 21 Setup (Full Auto)
# =========================
# Run this script as Administrator
$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager -AllUsers
Write-Host "Done."

Write-Host "Installing JDK 21 (Temurin)..." -ForegroundColor Cyan
winget install -e --id EclipseAdoptium.Temurin.21.JDK --silent

# Detect JDK install path
$jdkPath = (Get-ChildItem "C:\Program Files\Eclipse Adoptium\" -Directory |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
$javaBin  = Join-Path $jdkPath "bin"
$javaw    = Join-Path $javaBin "javaw.exe"

# ------------------------------
# Install JavaFX 21 manually
# ------------------------------
$fxBase    = "C:\Program Files\Java"
$fxFolder  = Join-Path $fxBase "javafx-sdk-21"
$fxZip     = Join-Path $env:TEMP "javafx-sdk-21.zip"
$fxUrl     = "https://download2.gluonhq.com/openjfx/21.0.5/openjfx-21.0.5_windows-x64_bin-sdk.zip"

if (-Not (Test-Path $fxFolder)) {
    Write-Host "Downloading JavaFX 21 SDK..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $fxUrl -OutFile $fxZip

    Write-Host "Extracting JavaFX 21 SDK to $fxBase ..." -ForegroundColor Cyan
    Expand-Archive -Path $fxZip -DestinationPath $fxBase -Force

    # The archive contains javafx-sdk-21.0.5, rename it to javafx-sdk-21 for consistency
    $extracted = Join-Path $fxBase "javafx-sdk-21.0.5"
    if (Test-Path $extracted) {
        Rename-Item -Path $extracted -NewName "javafx-sdk-21" -Force
    }

    Remove-Item $fxZip -Force
}

$fxPath = $fxFolder
$fxLib  = Join-Path $fxPath "lib"

# ------------------------------
# Set Environment Variables
# ------------------------------
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "Machine")

$oldPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($oldPath -notlike "*$javaBin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$javaBin;$oldPath", "Machine")
}

[System.Environment]::SetEnvironmentVariable("JAVAFX_HOME", $fxPath, "Machine")

# ------------------------------
# Associate .jar with JavaFX-enabled Java
# ------------------------------
Write-Host "Associating .jar files with Java 21 + JavaFX (all modules)..." -ForegroundColor Cyan
$modules = "javafx.base,javafx.graphics,javafx.controls,javafx.fxml,javafx.media,javafx.swing,javafx.web"
$command = "`"$javaw`" --module-path `"$fxLib`" --add-modules $modules -jar `"%1`" %*"
cmd /c "assoc .jar=jarfile"
cmd /c "ftype jarfile=$command"

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "JAVA_HOME  = $jdkPath"
Write-Host "JAVAFX_HOME= $fxPath"
Write-Host "Double-clicking .jar files will now always run with Java 21 + ALL JavaFX modules."
