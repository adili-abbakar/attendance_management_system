
#define MyAppName "UniAttend"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "UniAttend"
#define MyAppExeName "UniAttend.exe"

[Setup]
AppId={{7A8D9E21-5B34-4C62-9F81-3E6A2D7B1045}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\UniAttend
DefaultGroupName=UniAttend

OutputDir=installer
OutputBaseFilename=UniAttend-Setup

SetupIconFile=assets\images\logo.ico
UninstallDisplayIcon={app}\UniAttend.exe

Compression=lzma2
SolidCompression=yes
WizardStyle=modern

ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\UniAttend"; Filename: "{app}\UniAttend.exe"
Name: "{autodesktop}\UniAttend"; Filename: "{app}\UniAttend.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\UniAttend.exe"; Description: "Launch UniAttend"; Flags: postinstall nowait skipifsilent
