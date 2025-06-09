# VGitAliases para ZSH

Este módulo proporciona un conjunto completo de alias de Git para ZSH, inspirados en los alias de Oh My Zsh, pero organizados en un módulo independiente.

## Instalación

1. Clona este repositorio o copia el directorio `VGitAliases` a un directorio de tu elección.

2. Añade lo siguiente a tu archivo `.zshrc`:

```zsh
# Cargar módulo VGitAliases
source /ruta/a/VGitAliases/VGitAliases.zsh
```

Para este repositorio, agrega:

```zsh
# Cargar módulo VGitAliases
source /usr/share/zsh-vaayroon/VGitAliases/VGitAliases.zsh
```

## Características

- Alias comunes para operaciones Git (commit, push, pull, etc.)
- Funciones auxiliares para obtener información del repositorio
- Aliases modernos para `git switch` y `git restore`
- Función `gbclean` para eliminar ramas locales que ya no existen en remoto

## Ejemplos de uso

```zsh
# Operaciones básicas
g status               # git status
ga archivo.txt         # git add archivo.txt
gaa                    # git add --all
gcmsg "Mi commit"      # git commit -m "Mi commit"
gcs "Mi commit"        # git commit -S "Mi commit"

# Ramas
gb                     # git branch
gsw feature/nueva      # git switch feature/nueva
gswc feature/nueva     # git switch -c feature/nueva
gswm                   # git switch main (o master)
gswd                   # git switch develop

# Push/Pull
gp                     # git push
gpsup                  # git push --set-upstream origin [rama_actual]
gl                     # git pull

# Limpieza
gbclean                # Eliminar ramas locales que no existen en remoto
gbclean -D             # Forzar eliminación
gbclean -n             # Modo de prueba (no elimina nada)
```

## Autor

Condor Romero, Bryan Kevin
