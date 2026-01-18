# Fix Build Directory Permissions Issue

## Problem
Flutter cannot delete the `build` directory because it's locked by another process.

## Solutions (Try in order)

### Solution 1: Close IDEs and Processes
1. Close Visual Studio Code / Android Studio / IntelliJ IDEA
2. Close any File Explorer windows showing the project folder
3. Open Task Manager (Ctrl+Shift+Esc)
4. End processes:
   - `dart.exe`
   - `java.exe`
   - `gradle.exe`
   - `android-studio.exe`

### Solution 2: Manually Delete Build Directory
1. Close all IDEs and File Explorer
2. Open Command Prompt as Administrator
3. Navigate to project folder: `cd "C:\Users\sidhant mattoo\OneDrive\Desktop\project carefree"`
4. Run:
   ```
   rmdir /s /q build
   rmdir /s /q android\build
   rmdir /s /q android\app\build
   ```

### Solution 3: Use PowerShell (Run as Administrator)
```powershell
# Navigate to project
cd "C:\Users\sidhant mattoo\OneDrive\Desktop\project carefree"

# Kill processes
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*java*"} | Stop-Process -Force

# Wait 2 seconds
Start-Sleep -Seconds 2

# Delete directories
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "android\app\build" -Recurse -Force -ErrorAction SilentlyContinue
```

### Solution 4: Restart and Retry
1. Restart your computer
2. Run `flutter clean` again

### Solution 5: Move Project (Last Resort)
If OneDrive is causing issues:
1. Move project to a local folder (not OneDrive): `C:\Users\sidhant mattoo\Desktop\project carefree`
2. Or disable OneDrive sync for the project folder temporarily

## After Fixing
Run these commands:
```bash
flutter clean
flutter pub get
flutter run
```

## Prevention
- Close IDEs before running `flutter clean`
- Don't keep File Explorer open in the project folder
- Avoid having the build folder open in any application
