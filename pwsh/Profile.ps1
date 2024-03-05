function lsa() {Get-ChildItem && Get-ChildItem -Hidden -System}
function ll() {
	lsa;
}
function l() {
	lsa;
}
function nt {
    # Open new tab in current directory
    $currentPath = (Get-Location).Path
    wt.exe -w 0 new-tab -d $currentPath
}

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | 
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Garde-fou pour éviter d'exécuter involontairement la commande 'Set-Location'
Remove-Alias -Name sl -Force -ErrorAction SilentlyContinue
function sl() {
	Write-Warning "Prevented possible involotary execution of 'Set-Location' command. Use 'cd' to change directory instead.";
}

function gsts() {git status $args}
function gad() {git add $args}
function gdif() {git diff $args}

New-Alias -Name trash -Value Remove-ItemSafely
New-Alias -Name python3 -Value python
New-Alias -Name time -Value Measure-Command
New-Alias -Name nvmi -Value nvim
New-Alias -Name nvi -Value nvim
New-Alias -Name vi -Value vim
New-Alias -Name touch -Value New-Item

function DisplayColors {
	$colors = [enum]::GetValues([System.ConsoleColor])
	Foreach ($bgcolor in $colors) {
		Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
		Write-Host " on $bgcolor"
	}
}

function admin($applet) {
	Start-Process $applet -Verb runAs
}

function WelcomeMessage {
	if ($Host.UI.RawUI.WindowSize.Width -ge 70) {
		Write-Host " "
		Write-Host "    ____                              _____  __           __ __" -ForegroundColor DarkYellow
		Write-Host "   / __ \ ____  _      __ ___   _____/ ___/ / /_   ___   / // /" -ForegroundColor DarkYellow
		Write-Host "  / /_/ // __ \| | /| / // _ \ / ___/\__ \ / __ \ / _ \ / // / " -ForegroundColor DarkYellow
		Write-Host " / ____// /_/ /| |/ |/ //  __// /   ___/ // / / //  __// // /  " -ForegroundColor DarkYellow
		Write-Host "/_/     \____/ |__/|__/ \___//_/   /____//_/ /_/ \___//_//_/ 🔥 $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -ForegroundColor DarkYellow
		Write-Host " "
		Write-Host " "
	} else {
		Write-Host " "
		Write-Host "Microsoft PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -ForegroundColor DarkYellow
		Write-Host " "
	}
}

function CopyPath {
	Set-Clipboard ("'" + (Get-Location).Path + "'")
}
Set-Alias -Name cpy -Value CopyPath

WelcomeMessage
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\microverse-power.omp.json" | Invoke-Expression
