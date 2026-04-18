$ErrorActionPreference = "Stop"

Write-Host "== compile =="
.\gradlew.bat :app:compileDebugKotlin

Write-Host "== tests =="
.\gradlew.bat :app:testDebugUnitTest

Write-Host "== detekt =="
.\gradlew.bat :app:detekt