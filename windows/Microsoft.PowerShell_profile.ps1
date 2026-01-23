# Initialize fnm (Fast Node Manager) and use the appropriate Node.js version when changing directories
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
#fnm env --version-file-strategy=recursive --shell power-shell | Out-String | Invoke-Expression

# Imports the terminal Icons into curernt Instance of PowerShell
Import-Module Terminal-Icons

# Initialize Oh My Posh with the theme which we chosen
oh-my-posh init pwsh --config "$HOME\.k3v1n-powerlevel10k_rainbow.omp.json" | Invoke-Expression

# Set some useful Alias to shorten typing and save some key stroke
Set-Alias vim nvim 
Set-Alias ll ls 
Set-Alias g git 
Set-Alias cat bat
Set-Alias grep findstr
Set-Alias lla Get-ChildItem
Function lla { Get-ChildItem -Force -Recurse }

# Set Some Option for PSReadLine to show the history of our typed commands
Set-PSReadLineOption -PredictionSource History 
Set-PSReadLineOption -PredictionViewStyle ListView 
Set-PSReadLineOption -EditMode Windows

#Fzf (Import the fuzzy finder and set a shortcut key to begin searching)
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Utility Command that pushes the current branch and reduce keystrokes
function gitpushbrah {
  git push origin $(git branch --show-current)
}

# Utility Command that tells you where the absolute path of commandlets are
function which ($command) { 
  Get-Command -Name $command -ErrorAction SilentlyContinue | 
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue 
}

# Utility Command that remove deleted branchs from remote.
function gitclean {
  param(
    [string]$typeOfRemove = "-d"
  )

  if ($typeOfRemove -ne "-d" -and $typeOfRemove -ne "-D") {
    $typeOfRemove = "-d"
  }

  git remote prune origin

  git branch -vv | Select-String ': gone]' | Where-Object { $_ -notmatch "\*" } | ForEach-Object { ($_ -split '\s+')[1] |
    ForEach-Object {
      if ($_) {
        git branch $typeOfRemove $_
      }
    }
  }
}

# Function Name: mkdirhidden
# Description: This function creates a directory at the specified path.
# Then sets its attributes to hidden. If the directory already exists, it notifies the user.
# Usage: mkdirhidden "path_to_directory"
# Example: mkdirhidden ".vscode"
function mkdirhidden {
  param (
    [string]$Path
  )
  if (-not (Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType "directory"
    (Get-Item $Path).Attributes += "Hidden"
    Write-Host "Hidden directory created at $Path"
  }
  else {
    Write-Host "Directory already exists: $Path"
  }
}

function GetUatPwd {
  $filePath = "C:\Users\C20734E\OneDrive - EXPERIAN SERVICES CORP\MyDocs\uat.gpg"

  # run DecryptFile function
  DecryptFile -filePath $filePath
}

function GetKevB2BPwd {
  $filePath = "C:\Users\C20734E\OneDrive - EXPERIAN SERVICES CORP\MyDocs\kb2b.gpg"

  # run DecryptFile function
  DecryptFile -filePath $filePath
}

function GetUatB2BPwd {
  $filePath = "C:\Users\C20734E\OneDrive - EXPERIAN SERVICES CORP\MyDocs\EXPXML05_ub2b.gpg"

  # run DecryptFile function
  DecryptFile -filePath $filePath
}

function GetBryB2BPwd {
  $filePath = "C:\Users\C20734E\OneDrive - EXPERIAN SERVICES CORP\MyDocs\bb2b.gpg"

  # run DecryptFile function
  DecryptFile -filePath $filePath
}

function DecryptFile {
  param (
    [string]$filePath
  )

  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  # Check if the file path is provided
  if (-not $filePath) {
    Write-Error "File path is required."
    return
  }

  # Check if the file exists
  if (-not (Test-Path -Path $filePath)) {
    Write-Error "The file $filePath does not exist."
    return
  }
    
  try {
    # Run the gpg decrypt command and capture the output
    $fullOutput = gpg --decrypt $filePath 2>&1
        
    # Check if there was an error
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Failed to decrypt the file. Check if the password is correct."
      return
    }

    $pwdLine = ($fullOutput | Select-Object -Last 1).Trim()
        
    # Copy the decrypted content to clipboard
    $pwdLine | Set-Clipboard
        
    Write-Host "Decrypted content has been copied to clipboard." -ForegroundColor Green
  }
  catch {
    Write-Error "An error occurred: $_"
  }
}

function whichv {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  $cmd = Get-Command $Name -ErrorAction SilentlyContinue

  if ($cmd -and $cmd.ScriptBlock) {
    $cmd.ScriptBlock
  } elseif ($cmd) {
    Write-Host "'$Name' es un comando, pero no tiene ScriptBlock (no es una función definida en PowerShell)." -ForegroundColor Yellow
  } else {
    Write-Host "No se encontró ningún comando llamado '$Name'." -ForegroundColor Red
  }
}


function DotNetCoverageTests {
  if (Test-Path "testresult") {
    Remove-Item "testresult" -Recurse -Force
  }

  if (Test-Path "lcov.info") {
    Rename-Item "lcov.info" "lcov.info.bck" -Force
  }

  # Run tests with coverage collection
  dotnet test test/OAuthServer.Tests /p:CollectCoverage=true /p:CoverletOutput="../../testresult/" /p:CoverletOutputFormat=lcov
  # dotnet test Project.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/"
  # dotnet test Project.Application.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json"
  # dotnet test Project.Architecture.Tests /p:CollectCoverage=true /p:CoverletOutput="../testresult/" /p:MergeWith="../testresult/coverage.json" /p:CoverletOutputFormat=lcov

  # Copy the coverage report to lcov.info
  if (Test-Path "testresult/coverage.info") {
    Copy-Item "testresult/coverage.info" "lcov.info" -Force
  }
}

function DotNetCoverageTests {
  [CmdletBinding()]
  param(
    # Required base/workspace directory. Outputs will be placed here.
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BaseDir,

    # One or more test project or solution paths (relative to BaseDir or absolute).
    [Parameter(Mandatory = $true, Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$TestProjects
  )

  # Resolve and validate base directory
  $BaseDir = Resolve-Path -Path $BaseDir | Select-Object -ExpandProperty Path
  if (-not (Test-Path $BaseDir -PathType Container)) {
    throw "BaseDir '$BaseDir' does not exist or is not a directory."
  }

  # Paths within base dir
  $testResultDir = Join-Path $BaseDir "testresult"
  $lcovInBase    = Join-Path $BaseDir "lcov.info"
  $lcovBackup    = Join-Path $BaseDir "lcov.info.bck"

  # Clean previous outputs
  if (Test-Path $testResultDir) {
    Remove-Item $testResultDir -Recurse -Force
  }
  New-Item -ItemType Directory -Path $testResultDir -Force | Out-Null

  if (Test-Path $lcovInBase) {
    if (Test-Path $lcovBackup) {
      Remove-Item $lcovBackup -Force
    }
    Rename-Item $lcovInBase $lcovBackup -Force
  }

  # Coverage files
  $jsonOutput = Join-Path $testResultDir "coverage.json"
  $lcovOutput = Join-Path $testResultDir "coverage.info"

  $first = $true
  foreach ($projPath in $TestProjects) {
    # Resolve project path relative to BaseDir if it's not absolute
    if ([System.IO.Path]::IsPathRooted($projPath)) {
      $resolvedProj = $projPath
    } else {
      $resolvedProj = Join-Path $BaseDir $projPath
    }

    if (-not (Test-Path $resolvedProj)) {
      throw "Test project path not found: '$resolvedProj'"
    }

    # Prepare dotnet test properties
    $props = @(
      "/p:CollectCoverage=true",
      "/p:CoverletOutput=`"$($testResultDir.TrimEnd('\','/'))/`""
    )

    if ($first) {
      # First run initializes JSON and produces LCOV
      $props += "/p:CoverletOutputFormat=`"json,lcov`""
      $first = $false
    } else {
      # Subsequent runs merge into existing JSON and also produce LCOV
      $props += "/p:MergeWith=`"$jsonOutput`""
      $props += "/p:CoverletOutputFormat=`"json,lcov`""
    }

    Write-Host "Running tests with coverage for: $resolvedProj"
    dotnet test $resolvedProj @props
    if ($LASTEXITCODE -ne 0) {
      throw "dotnet test failed for '$resolvedProj'"
    }
  }

  # Copy final LCOV to base dir root as lcov.info
  if (Test-Path $lcovOutput) {
    Copy-Item $lcovOutput $lcovInBase -Force
    Write-Host "Coverage LCOV written to: $lcovInBase"
  } else {
    Write-Warning "Could not find '$lcovOutput'. Ensure coverlet produced LCOV. Check test logs."
  }
}

Import-Module VGitAliases -DisableNameChecking
Import-Module VClip -DisableNameChecking
