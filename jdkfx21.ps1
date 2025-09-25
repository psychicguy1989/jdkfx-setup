# =========================
# Java 21 + JavaFX 21 Setup (with ALL JavaFX modules for JARs)
# =========================
# Run this script *as Administrator*

Write-Host "Installing JDK 21 (Temurin)..." -ForegroundColor Cyan
winget install -e --id EclipseAdoptium.Temurin.21.JDK --silent

Write-Host "Installing JavaFX 21 (GluonHQ)..." -ForegroundColor Cyan
winget install -e --id GluonHQ.JavaFX.21 --silent

# Detect install paths
$jdkPath = (Get-ChildItem "C:\Program Files\Eclipse Adoptium\" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
$javaBin  = Join-Path $jdkPath "bin"
$javaw    = Join-Path $javaBin "javaw.exe"

$fxPath = (Get-ChildItem "C:\Program Files\Java\" -Directory | Where-Object { $_.Name -like "javafx-sdk-21*" } | Select-Object -First 1).FullName
$fxLib  = Join-Path $fxPath "lib"

# Set JAVA_HOME + PATH (machine-wide)
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "Machine")
$oldPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($oldPath -notlike "*$javaBin*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$javaBin;$oldPath", "Machine")
}

# Add JAVAFX_HOME env var
[System.Environment]::SetEnvironmentVariable("JAVAFX_HOME", $fxPath, "Machine")

# Associate .jar files with Java 21 + ALL JavaFX modules
Write-Host "Associating .jar files with Java 21 + JavaFX (all modules)..." -ForegroundColor Cyan
$modules = "javafx.base,javafx.graphics,javafx.controls,javafx.fxml,javafx.media,javafx.swing,javafx.web"
$command = "`"$javaw`" --module-path `"$fxLib`" --add-modules $modules -jar `"%1`" %*"
cmd /c "assoc .jar=jarfile"
cmd /c "ftype jarfile=$command"

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "JAVA_HOME  = $jdkPath"
Write-Host "JAVAFX_HOME= $fxPath"
Write-Host "Double-clicking .jar files will now always run with Java 21 + ALL JavaFX modules."
