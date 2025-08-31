# Initialize fnm (Fast Node Manager) and use the appropriate Node.js version when changing directories
fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
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

function GetBryB2BPwd {
  $filePath = "C:\Users\C20734E\OneDrive - EXPERIAN SERVICES CORP\MyDocs\bb2b.gpg"

  # run DecryptFile function
  DecryptFile -filePath $filePath
}

function DecryptFile {
  param (
    [string]$filePath
  )

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

Import-Module VGitAliases -DisableNameChecking
Import-Module VClip -DisableNameChecking
