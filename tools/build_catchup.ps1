param([string]$Zig='zig')
$ErrorActionPreference='Stop'
$wirelessRoot=Split-Path $PSScriptRoot -Parent
Push-Location $wirelessRoot
try {
    New-Item -ItemType Directory -Path build-native -Force | Out-Null
    $wirelessNativeSources=@('native/third_party/minhook/src/hook.c','native/third_party/minhook/src/buffer.c',
        'native/third_party/minhook/src/trampoline.c','native/third_party/minhook/src/hde/hde64.c')
    & $Zig cc -shared -O2 -std=c11 -Wall -Wextra -Werror native/catchup.c @wirelessNativeSources -lbcrypt -o build-native/caretaker_catchup.dll
    if($LASTEXITCODE){throw 'Native guard build failed'}
    & $Zig cc -O2 -std=c11 -Wall -Wextra -Werror -Wno-unused-function -Wno-unused-variable native/test_catchup.c -o build-native/test_catchup.exe
    if($LASTEXITCODE){throw 'Native test build failed'}
    & ./build-native/test_catchup.exe
    if($LASTEXITCODE){throw 'Native guard tests failed'}
    Copy-Item -LiteralPath build-native/caretaker_catchup.dll -Destination Voyage/Binaries/Win64/ue4ss/Mods/CaretakerWirelessBackground/Scripts/native/caretaker_catchup.dll -Force
} finally {Pop-Location}
