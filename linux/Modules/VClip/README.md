# VClip para ZSH

Este módulo proporciona comandos para interactuar con el portapapeles desde la línea de comandos en sistemas Linux, utilizando `xclip`.

## Requisitos

- `xclip` instalado en el sistema
  ```bash
  sudo apt-get install xclip    # Debian/Ubuntu
  sudo dnf install xclip        # Fedora
  sudo pacman -S xclip          # Arch Linux
  ```

## Instalación

1. Asegúrate de tener `xclip` instalado.
2. Añade lo siguiente a tu archivo `.zshrc`:

```zsh
# Cargar módulo VClip
source /usr/share/zsh-vaayroon/VClip/VClip.zsh
```

## Comandos disponibles

### vclip

Copia texto al portapapeles desde stdin o desde un archivo.

```bash
# Copiar desde stdin
echo "Hola mundo" | vclip

# Copiar desde un archivo
vclip archivo.txt
```

### vclipf

Copia el contenido de un archivo al portapapeles.

```bash
vclipf archivo.txt
```

### vpaste

Muestra el contenido actual del portapapeles.

```bash
vpaste
```

### vclipshow

Muestra el contenido del portapapeles con un mensaje informativo.

```bash
vclipshow
```

### vclipclear

Limpia el contenido del portapapeles.

```bash
vclipclear
```

## Ejemplos de uso

```bash
# Copiar la salida de un comando
ls -la | vclip

# Copiar el contenido de un archivo
vclipf ~/.zshrc

# Ver lo que está en el portapapeles
vpaste

# Limpiar el portapapeles
vclipclear
```

## Autor

Condor Romero, Bryan Kevin
