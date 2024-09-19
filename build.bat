set "py=%cd%\env\Scripts\python.exe"

IF EXIST %py% (
    echo "Using VENV Python"
) ELSE (
    set "py=python"
    echo "Using system Python"
)


@echo off

%py% -m pip install -r requirements.txt

%py% scripts/apply_versions.py

%py% scripts/get_contributors.py

rmdir /Q /S wingetuiBin


mkdir wingetui_bin
xcopy wingetui wingetui_bin\wingetui /E /H /C /I /Y
pushd wingetui_bin\wingetui

%py% -m compileall -b .
if %errorlevel% neq 0 goto:error

del /S *.py
copy ..\..\wingetui\launcher.py .\
del launcher.pyc

%py% ..\..\scripts\generate_integrity.py --buildfiles

rmdir /Q /S __pycache__
rmdir /Q /S .vscode
rmdir /Q /S ExternalLibraries\__pycache__
rmdir /Q /S ExternalLibraries\PyWebView2\__pycache__
rmdir /Q /S Core\__pycache__
rmdir /Q /S Core\Data\__pycache__
rmdir /Q /S Core\Languages\__pycache__
rmdir /Q /S Interface\__pycache__
rmdir /Q /S Interface\CustomWidgets\__pycache__
rmdir /Q /S PackageEngine\__pycache__
rmdir /Q /S PackageEngine\Managers\__pycache__
rmdir /Q /S build
rmdir /Q /S dist

move launcher.py ..\launcher.py
move Win.spec ..\Win.spec

popd
pushd wingetui_bin

%py% -m PyInstaller "Win.spec"
@REM if %errorlevel% neq 0 goto:error

@REM timeout 5

@REM pushd dist\wingetuiBin\wingetui
@REM move choco-cli ..\choco-cli
@REM popd

@REM pushd dist\wingetuiBin\PySide6
@REM del opengl32sw.dll
@REM del Qt6Quick.dll
@REM del Qt6Qml.dll
@REM del Qt6Pdf.dll
@REM del Qt6OpenGL.dll
@REM del Qt6QmlModels.dll
@REM del Qt6Network.dll
@REM del Qt6DataVisualization.dll
@REM del Qt6VirtualKeyboard.dll
@REM del QtDataVisualization.pyd
@REM del QtOpenGL.pyd
@REM popd 
@REM pushd dist\wingetuiBin\choco-cli
@REM rmdir /Q /S .chocolatey
@REM rmdir /Q /S lib
@REM rmdir /Q /S lib-bad
@REM rmdir /Q /S lib-bkp
@REM rmdir /Q /S logs
@REM mkdir lib
@REM mkdir logs
@REM mkdir .chocolatey
@REM mkdir lib-bad
@REM mkdir lib-bkp
@REM popd

@REM move dist\wingetuiBin ..\
@REM popd
@REM rmdir /Q /S wingetui_bin

@REM "Y:\- Signing\signtool-x64\signtool.exe" sign /v /debug /fd SHA256 /tr "http://timestamp.acs.microsoft.com" /td SHA256 /dlib "Y:\- Signing\azure.codesigning.client\x64\Azure.CodeSigning.Dlib.dll" /dmdf "Y:\- Signing\metadata.json" "wingetuiBin/wingetui.exe"
@REM pause

@REM set INSTALLATOR="%SYSTEMDRIVE%\Program Files (x86)\Inno Setup 6\ISCC.exe"
@REM if exist %INSTALLATOR% (
@REM     %INSTALLATOR% "WingetUI.iss"
@REM     echo You may now sign the installer
@REM     "Y:\- Signing\signtool-x64\signtool.exe" sign /v /debug /fd SHA256 /tr "http://timestamp.acs.microsoft.com" /td SHA256 /dlib "Y:\- Signing\azure.codesigning.client\x64\Azure.CodeSigning.Dlib.dll" /dmdf "Y:\- Signing\metadata.json" "WingetUI Installer.exe"
@REM     pause
@REM     "wingetui Installer.exe"
@REM ) else (
@REM     echo "Make installer was skipped, because the installer is missing."
@REM     echo "Running WingetUI..."
@REM     start /b wingetuiBin/wingetui.exe
@REM )

@REM goto:end

@REM :error
@REM echo "Error!"

@REM :end
@REM pause
