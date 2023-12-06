# Dot source our functions.
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') -File | ForEach-Object {
    . $_.FullName
}
