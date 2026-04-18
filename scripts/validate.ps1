$ErrorActionPreference = "Stop"

$jbrPath = "C:\Program Files\Android\Android Studio1\jbr"
if (Test-Path $jbrPath) {
    $env:JAVA_HOME = $jbrPath
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
}

Write-Host "== compile =="
.\gradlew.bat :app:compileDebugKotlin

Write-Host "== tests =="
.\gradlew.bat :app:testDebugUnitTest

Write-Host "== detekt =="
.\gradlew.bat :app:detekt