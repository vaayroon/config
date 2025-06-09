#!/usr/bin/env zsh
# VGitAliases.zsh
# Implementación de los alias de git de Oh My Zsh
# Author: Condor Romero, Bryan Kevin

# Funciones auxiliares
function git_current_branch() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -z "$branch" ]]; then
    branch=$(git rev-parse --short HEAD 2>/dev/null)
  fi
  echo $branch
}

function git_main_branch() {
  local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
  if [[ -n "$main_branch" ]]; then
    main_branch=${main_branch#refs/remotes/origin/}
  else
    # Intentar detectar si existe main o master
    if git show-ref --verify refs/heads/main >/dev/null 2>&1; then
      main_branch="main"
    elif git show-ref --verify refs/heads/master >/dev/null 2>&1; then
      main_branch="master"
    fi
  fi
  echo $main_branch
}

function git_develop_branch() {
  if git show-ref --verify refs/heads/develop >/dev/null 2>&1; then
    echo "develop"
  elif git show-ref --verify refs/heads/dev >/dev/null 2>&1; then
    echo "dev"
  fi
}

function git_uat_branch() {
  if git show-ref --verify refs/heads/uat >/dev/null 2>&1; then
    echo "uat"
  elif git show-ref --verify refs/heads/staging >/dev/null 2>&1; then
    echo "staging"
  fi
}

function git_production_branch() {
  if git show-ref --verify refs/heads/production >/dev/null 2>&1; then
    echo "production"
  elif git show-ref --verify refs/heads/pro >/dev/null 2>&1; then
    echo "pro"
  fi
}

# Alias básicos de git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gap='git apply'

# Alias para branch
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbm='git branch -m' # Renombrar rama actual

# Alias para switch (moderno) en lugar de checkout
alias gsw='git switch'
alias gswc='git switch -c' # Crear y cambiar a nueva rama
alias gswm='git switch $(git_main_branch)' # Cambiar a rama principal
function gswd() {
  local dev_branch=$(git_develop_branch)
  if [[ -n "$dev_branch" ]]; then
    git switch $dev_branch
  else
    echo "No se encontró una rama de desarrollo (develop/dev)" >&2
  fi
}
function gswu() {
  local uat_branch=$(git_uat_branch)
  if [[ -n "$uat_branch" ]]; then
    git switch $uat_branch
  else
    echo "No se encontró una rama de UAT (uat/staging)" >&2
  fi
}
function gswp() {
  local prod_branch=$(git_production_branch)
  if [[ -n "$prod_branch" ]]; then
    git switch $prod_branch
  else
    echo "No se encontró una rama de producción (production/pro)" >&2
  fi
}

# Mantener algunos alias de checkout por compatibilidad
alias gco='git switch'
alias gcb='git switch -c'
alias gcm='git switch $(git_main_branch)'

# Alias para restore (moderno)
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'

# Alias para commit
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcam='git commit -a -m'
alias gcsm='git commit -s -m'
alias gcf='git config --list'
alias gcmsg='git commit -m'
alias gcs='git commit -S' # Commit con firma GPG

# Alias para diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'

# Alias para fetch
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# Alias para pull/push
alias gl='git pull'
alias ggl='git pull origin $(git_current_branch)'
alias gp='git push'
alias ggp='git push origin $(git_current_branch)'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpf='git push --force-with-lease' # Más seguro que --force
alias gpf!='git push --force'

# Alias para status
alias gst='git status'
alias gsb='git status -sb'
alias gss='git status -s'

# Alias para stash
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstu='git stash --include-untracked'
alias gstall='git stash --all'

# Alias para log
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'

# Alias para remote
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote -v'
alias grset='git remote set-url'
alias grup='git remote update'

# Alias para reset
alias grh='git reset'
alias grhh='git reset --hard'
alias groh='git reset origin/$(git_current_branch) --hard'

# Alias para rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias grbs='git rebase --skip'

# Alias para merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'

# Alias para worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtrm='git worktree remove'

# Alias para clean
alias gclean='git clean -id'
alias gpristine='git reset --hard && git clean -dffx'

# Alias para submodules
alias gsi='git submodule init'
alias gsu='git submodule update'

# Alias útiles
alias grt='cd $(git rev-parse --show-toplevel)' # Ir a la raíz del repositorio
alias gcount='git shortlog -sn' # Contar commits por autor

function gwip() {
  git add -A
  git ls-files --deleted -z | xargs -r0 git rm >/dev/null 2>&1
  git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
}

function gunwip() {
  if git log -n 1 | grep -q "\-\-wip\-\-"; then
    git reset HEAD~1
  else
    echo "No hay commit WIP para deshacer" >&2
  fi
}

# Elimina ramas locales que ya no existen en remoto (gone)
function gbclean() {
  emulate -L zsh
  local -A opthash
  zparseopts -D -A opthash -- d=flag_soft D=flag_force n=flag_dry_run
  
  local delete_flag="-d"
  local remote="origin"
  local force=false
  local dry_run=false
  
  # Procesar argumentos
  if (( ${#flag_force} )); then
    delete_flag="-D"
  elif (( ${#flag_soft} )); then
    delete_flag="-d"
  fi
  
  if (( ${#flag_dry_run} )); then
    dry_run=true
  fi
  
  # Actualizar referencias remotas
  echo "\033[0;36m🔄 Actualizando referencias remotas...\033[0m"
  git remote prune $remote
  
  # Obtener ramas locales que ya no están en remoto
  echo "\033[0;36m🔍 Buscando ramas locales sin equivalente remoto...\033[0m"
  local current_branch=$(git_current_branch)
  local -a gone_branches
  gone_branches=($(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | 
                  grep '\[gone\]$' | 
                  awk '{print $1}' | 
                  grep -v "^$current_branch\$"))
  
  # Si no hay ramas para eliminar
  if (( ${#gone_branches} == 0 )); then
    echo "\033[0;32m✅ No se encontraron ramas locales para eliminar.\033[0m"
    return 0
  fi
  
  # Mostrar ramas que serán eliminadas
  echo "\033[0;33m🗑️ Ramas locales que serán eliminadas:\033[0m"
  for branch in $gone_branches; do
    echo "\033[0;33m   - $branch\033[0m"
  done
  
  # Si es una ejecución de prueba, terminar aquí
  if [[ "$dry_run" == true ]]; then
    echo "\033[0;36mℹ️ Modo de prueba: No se ha eliminado ninguna rama.\033[0m"
    return 0
  fi
  
  # Solicitar confirmación si no está en modo forzado
  if [[ "$force" == false ]]; then
    echo -n "¿Eliminar estas ramas? (s/N) "
    read confirmation
    if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
      echo "\033[0;31m❌ Operación cancelada.\033[0m"
      return 1
    fi
  fi
  
  # Eliminar las ramas
  local deleted_count=0
  local error_count=0
  
  for branch in $gone_branches; do
    echo -n "\033[0;36m🗑️ Eliminando rama: $branch\033[0m"
    if git branch $delete_flag $branch 2>/dev/null; then
      echo " \033[0;32m✅\033[0m"
      ((deleted_count++))
    else
      echo " \033[0;31m❌\033[0m"
      echo "\033[0;31m   Error al eliminar la rama $branch\033[0m"
      ((error_count++))
    fi
  done
  
  # Resumen final
  echo "\n\033[0;36m🎉 Resumen:\033[0m"
  echo "\033[0;32m   ✅ Ramas eliminadas: $deleted_count\033[0m"
  if (( error_count > 0 )); then
    echo "\033[0;31m   ❌ Errores: $error_count\033[0m"
    echo "\033[0;33m      Para forzar eliminación, utiliza: gbclean -D\033[0m"
  fi
}

