# $Global:lastVisited = (Get-Location).Path;
$codesource = [PSCustomObject]@{
	libs = 'C:\Users\antho\documents\code\ressources\librairies\'
	apis = 'C:\Users\antho\documents\code\ressources\APIs\'
	logos = 'C:\Users\antho\documents\code\ressources\Logos\'
	polices = 'C:\Users\antho\documents\code\ressources\polices\'
	sons = 'C:\Users\antho\documents\code\ressources\sons\'
	sounds = 'C:\Users\antho\documents\code\ressources\sons\'
}

# Global variables for common folders
$Global:codesource = $codesource;
$Global:code = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/Code"); # Legacy
$Global:development = $(Join-Path -Path $env:USERPROFILE -ChildPath "Development");
$Global:dev = $Global:development
$Global:source = $(Join-Path -Path $env:USERPROFILE -ChildPath "source");
$Global:notes = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/Notes");

# Project shortcuts
$Global:bdemmilaval = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/BDE/WEB/BDEMMILAVAL.FR/WWW");
$Global:iut = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/S5");
$Global:bde = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/BDE");
$Global:biblio = $(Join-Path -Path $env:USERPROFILE -ChildPath "Development/biblio/www");
$Global:arsenal = $(Join-Path -Path $env:USERPROFILE -ChildPath "Development/arsenal/www");
$Global:sae = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/S5/SAE501/iut-s5");
$Global:pomo = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/S5/R507/pomodoro");
$Global:memoire = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/S5/memoire");
$Global:retro = $(Join-Path -Path $env:USERPROFILE -ChildPath "Documents/IUT/S5/R507/pomodoro");


# Quick file access
$Global:nvimprofile= $(Join-Path -Path $env:LOCALAPPDATA -ChildPath "nvim/init.lua");

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

function neorg() {
	param(
		[switch]$iut
	)

	$workspace = "personal";

	if ($PSBoundParameters.ContainsKey('iut')) {
		$workspace = "iut";
	}

	mkdir -Force -Path "$env:TEMP\neorg-void" | Out-Null;
	nvim $env:TEMP\neorg-void -c "call LoadNeorgWorkspace('$workspace')";
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
New-Alias -Name touch -Value New-Item

# function Prompt {
# 	if ($Global:lastVisited -ne (Get-Location).Path) {
# 		# On "cd"
# 	}
# 	$Global:lastVisited = (Get-Location).Path;
# 	$currentFolderName = $((Get-Location).Path.Substring((Get-Location).Path.LastIndexOf("\")+1));
# 	if ($currentFolderName.length -gt 0) {
# 		$Host.UI.RawUI.WindowTitle = "$currentFolderName - PowerShell 7";
# 	} else {
#		$Host.UI.RawUI.WindowTitle = "PowerShell 7";
# 	}
# 	Write-Host -NoNewLine "PS " -ForegroundColor DarkGray
# 	Write-Host -NoNewline ($env:USERNAME).ToLower() -BackgroundColor Black -ForegroundColor Green
# 	Write-Host -NoNewline "@💻" -BackgroundColor Black -ForegroundColor Green
# 	Write-Host -NoNewLine $((HOSTNAME.EXE)).ToLower() -ForegroundColor Green
# 	$resolvedPath = (Get-Location).Path
# 	if ((Get-Location).Path.StartsWith("C:\Users\$($env:USERNAME)")) {
# 		$resolvedPath = $resolvedPath.Replace("C:\Users\$($env:USERNAME)", "~")
# 	} else {
# 		$resolvedPath = ">$resolvedPath"
# 	}
# 	$resolvedPath = $resolvedPath.Replace('\', '/')
# 	$lastPosition = 0;
# 	$slashes = 0;
# 	while ($lastPosition -ne -1) {
# 		$lastPosition = $resolvedPath.IndexOf('/', ($lastPosition+1));
# 		if ($lastPosition -gt -1) {
# 			$slashes += 1;
# 		}
# 	}
# 	if ($slashes -gt 4) {
# 		# Obtenir l'index du 4ème slash en partant de la fin
# 		$lastPosition = $resolvedPath.length;
# 		for ($i = 0; $i -lt 4; $i++) {
# 			$lastPosition--
# 			$lastPosition = $resolvedPath.LastIndexOf('/', $lastPosition, $lastPosition);
# 		}
# 		$resolvedPath = $resolvedPath.Substring($lastPosition)
# 		Write-Host -NoNewLine " "
# 		Write-Host -NoNewLine "[…]" -BackgroundColor DarkYellow -ForegroundColor White
# 	}
# 	Write-Host -NoNewline $resolvedPath -ForegroundColor DarkCyan

# 	Return " "
# }

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

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_mocha.omp.json" | Invoke-Expression
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\microverse-power.omp.json" | Invoke-Expression
