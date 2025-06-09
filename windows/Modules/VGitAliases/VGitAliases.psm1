# Funciones auxiliares
function Get-GitCurrentBranch {
  $branch = git symbolic-ref --short HEAD 2>$null
  if (-not $branch) {
    $branch = git rev-parse --short HEAD 2>$null
  }
  return $branch
}

function Get-GitMainBranch {
  $mainBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
  if ($mainBranch) {
    $mainBranch = $mainBranch -replace "refs/remotes/origin/", ""
  } else {
    # Intentar detectar si existe main o master
    if (git show-ref --verify refs/heads/main) {
      $mainBranch = "main"
    } elseif (git show-ref --verify refs/heads/master) {
      $mainBranch = "master"
    }
  }
  return $mainBranch
}

function Get-GitDevelopBranch {
  if (git show-ref --verify refs/heads/develop) {
    "develop"
  } elseif (git show-ref --verify refs/heads/dev) {
    "dev"
  } else {
    $null
  }
}

function Get-GitUatBranch {
  if (git show-ref --verify refs/heads/uat) {
    return "uat"
  } elseif (git show-ref --verify refs/heads/staging) {
    return "staging"
  }
  return $null
}

function Get-GitProductionBranch {
  if (git show-ref --verify refs/heads/production) {
    return "production"
  } elseif (git show-ref --verify refs/heads/pro) {
    return "pro"
  }
  return $null
}

# Alias básicos de git
Set-Alias -Name g -Value git -Scope Global
function global:ga { git add $args }
function global:gaa { git add --all $args }
function global:gapa { git add --patch $args }
function global:gau { git add --update $args }
function global:gav { git add --verbose $args }
function global:gap { git apply $args }

# Alias para branch
function global:gb { git branch $args }
function global:gba { git branch -a $args }
function global:gbd { git branch -d $args }
function global:gbD { git branch -D $args }
function global:gbl { git blame -b -w $args }
function global:gbnm { git branch --no-merged $args }
function global:gbr { git branch --remote $args }
function global:gbm { git branch -m $args } # Renombrar rama actual

# Alias para switch (moderno) en lugar de checkout
function global:gsw { git switch $args }
function global:gswc { git switch -c $args } # Crear y cambiar a nueva rama
function global:gswm { git switch $(Get-GitMainBranch) } # Cambiar a rama principal
function global:gswd { 
  $devBranch = Get-GitDevelopBranch
  if ($devBranch) {
    git switch $devBranch
  } else {
    Write-Error "No se encontró una rama de desarrollo (develop/dev)"
  }
}
function global:gswu { 
  $devBranch = Get-GitUatBranch
  if ($devBranch) {
    git switch $devBranch
  } else {
    Write-Error "No se encontró una rama de UAT (uat/staging)"
  }
}
function global:gswp { 
  $devBranch = Get-GitProductionBranch
  if ($devBranch) {
    git switch $devBranch
  } else {
    Write-Error "No se encontró una rama de producción (production/pro)"
  }
}

# Mantener algunos alias de checkout por compatibilidad
function global:gco { git switch $args }
function global:gcb { git switch -c $args }
function global:gcm { git switch $(Get-GitMainBranch) }

# Alias para restore (moderno)
function global:grs { git restore $args }
function global:grss { git restore --source $args }
function global:grst { git restore --staged $args }

# Alias para commit
function global:gc { git commit -v $args }
function global:gc! { git commit -v --amend $args }
function global:gcn! { git commit -v --no-edit --amend $args }
function global:gca { git commit -v -a $args }
function global:gca! { git commit -v -a --amend $args }
function global:gcan! { git commit -v -a --no-edit --amend $args }
function global:gcam { git commit -a -m $args }
function global:gcsm { git commit -s -m $args }
function global:gcf { git config --list $args }
function global:gcmsg { git commit -m $args }

# Alias para diff
function global:gd { git diff $args }
function global:gdca { git diff --cached $args }
function global:gdcw { git diff --cached --word-diff $args }
function global:gds { git diff --staged $args }
function global:gdt { git diff-tree --no-commit-id --name-only -r $args }
function global:gdw { git diff --word-diff $args }

# Alias para fetch
function global:gf { git fetch $args }
function global:gfa { git fetch --all --prune $args }
function global:gfo { git fetch origin $args }

# Alias para pull/push
function global:gl { git pull $args }
function global:ggl { git pull origin $(Get-GitCurrentBranch) }
function global:gp { git push $args }
function global:ggp { git push origin $(Get-GitCurrentBranch) }
function global:gpsup { git push --set-upstream origin $(Get-GitCurrentBranch) }
function global:gpf { git push --force-with-lease $args } # Más seguro que --force
function global:gpf! { git push --force $args }

# Alias para status
function global:gst { git status $args }
function global:gsb { git status -sb $args }
function global:gss { git status -s $args }

# Alias para stash
function global:gsta { git stash push $args }
function global:gstaa { git stash apply $args }
function global:gstc { git stash clear $args }
function global:gstd { git stash drop $args }
function global:gstl { git stash list $args }
function global:gstp { git stash pop $args }
function global:gsts { git stash show --text $args }
function global:gstu { git stash --include-untracked $args }
function global:gstall { git stash --all $args }

# Alias para log
function global:glg { git log --stat $args }
function global:glgp { git log --stat -p $args }
function global:glgg { git log --graph $args }
function global:glgga { git log --graph --decorate --all $args }
function global:glo { git log --oneline --decorate $args }
function global:glog { git log --oneline --decorate --graph $args }
function global:gloga { git log --oneline --decorate --graph --all $args }
function global:glol { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' $args }
function global:glola { git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all $args }

# Alias para remote
function global:gr { git remote $args }
function global:gra { git remote add $args }
function global:grv { git remote -v $args }
function global:grset { git remote set-url $args }
function global:grup { git remote update $args }

# Alias para reset
function global:grh { git reset $args }
function global:grhh { git reset --hard $args }
function global:groh { git reset origin/$(Get-GitCurrentBranch) --hard $args }

# Alias para rebase
function global:grb { git rebase $args }
function global:grba { git rebase --abort $args }
function global:grbc { git rebase --continue $args }
function global:grbi { git rebase -i $args }
function global:grbm { git rebase $(Get-GitMainBranch) $args }
function global:grbs { git rebase --skip $args }

# Alias para merge

# Eliminar alias conflictivo con Get-Member (gm)
if (Get-Command gm -ErrorAction SilentlyContinue) {
  Remove-Item alias:gm -Force
}

function global:gm { git merge $args }
function global:gma { git merge --abort $args }
function global:gmom { git merge origin/$(Get-GitMainBranch) $args }
function global:gmum { git merge upstream/$(Get-GitMainBranch) $args }

# Alias para worktree
function global:gwt { git worktree $args }
function global:gwta { git worktree add $args }
function global:gwtls { git worktree list $args }
function global:gwtrm { git worktree remove $args }

# Alias para clean
function global:gclean { git clean -id $args }
function global:gpristine { git reset --hard && git clean -dffx $args }

# Alias para submodules
function global:gsi { git submodule init $args }
function global:gsu { git submodule update $args }

# Alias útiles
function global:grt { Set-Location (git rev-parse --show-toplevel) } # Ir a la raíz del repositorio
function global:gcount { git shortlog -sn $args } # Contar commits por autor
function global:gwip { 
  git add -A
  git rm $(git ls-files --deleted) 2> $null
  git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]" 
}
function global:gunwip { 
  if (git log -n 1 | Select-String -Pattern "--wip--" -Quiet) {
    git reset HEAD~1
  } else {
    Write-Error "No hay commit WIP para deshacer"
  }
}

# Elimina ramas locales que ya no existen en remoto (gone)
function global:gbclean {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0)]
    [ValidateSet("-d", "-D")]
    [string]$DeleteFlag = "-d",

    [Parameter(Position = 1)]
    [string]$Remote = "origin",

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$DryRun
  )

  # Actualizar referencias remotas
  Write-Host "🔄 Actualizando referencias remotas..." -ForegroundColor Cyan
  git remote prune $Remote

  # Obtener ramas locales que ya no están en remoto
  Write-Host "🔍 Buscando ramas locales sin equivalente remoto..." -ForegroundColor Cyan
  $goneBranches = @(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads |
    Where-Object { $_ -match '\[gone\]$' } |
    ForEach-Object { ($_ -split '\s+')[0] } |
    Where-Object { $_ -ne $(Get-GitCurrentBranch) })
  
  # Si no hay ramas para eliminar
  if ($goneBranches.Count -eq 0) {
    Write-Host "✅ No se encontraron ramas locales para eliminar." -ForegroundColor Green
    return
  }
  
  # Mostrar ramas que serán eliminadas
  Write-Host "🗑️ Ramas locales que serán eliminadas:" -ForegroundColor Yellow
  $goneBranches | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
  
  # Si es una ejecución de prueba, terminar aquí
  if ($DryRun) {
    Write-Host "ℹ️ Modo de prueba: No se ha eliminado ninguna rama." -ForegroundColor Cyan
    return
  }
  
  # Solicitar confirmación si no está en modo forzado
  if (-not $Force) {
    $confirmation = Read-Host "¿Eliminar estas ramas? (s/N)"
    if ($confirmation -notmatch '^[sS]$') {
      Write-Host "❌ Operación cancelada." -ForegroundColor Red
      return
    }
  }
  
  # Eliminar las ramas
  $deletedCount = 0
  $errorCount = 0
  
  foreach ($branch in $goneBranches) {
    Write-Host "🗑️ Eliminando rama: $branch" -ForegroundColor Cyan -NoNewline
    $output = git branch $DeleteFlag $branch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
      Write-Host " ✅" -ForegroundColor Green
      $deletedCount++
    } else {
      Write-Host " ❌" -ForegroundColor Red
      Write-Host "   $output" -ForegroundColor Red
      $errorCount++
    }
  }
  
  # Resumen final
  Write-Host "`n🎉 Resumen:" -ForegroundColor Cyan
  Write-Host "   ✅ Ramas eliminadas: $deletedCount" -ForegroundColor Green
  if ($errorCount -gt 0) {
    Write-Host "   ❌ Errores: $errorCount" -ForegroundColor Red
    Write-Host "      Para forzar eliminación, utiliza: gbclean -D -Force" -ForegroundColor Yellow
  }
}

# Exportar las funciones para que estén disponibles al importar el módulo
Export-ModuleMember -Function * -Alias *
