# BetterPosada – Addon para UltimoWoW

<img width="285" height="285" alt="betterPosada" src="https://github.com/user-attachments/assets/8e925877-1b98-4310-9233-2c40f6818f60" />

BetterPosada es un addon para World of Warcraft 3.3.5a (como UltimoWoW), diseñado para mejorar la experiencia del chat de posada: filtrar mensajes, destacar tipo de contenido, y facilitar reportes compartidos entre jugadores.

## ✨ Características principales

- **Interfaz limpia y ordenada** para el chat de posada: cada mensaje en su recuadro, con borde y temática visual configurable.  
- **Animaciones** configurables para aparición de mensajes: _fade_, _grow_, _shine_ o _glow_.  
- **Temas visuales** personalizables: `dark`, `warm`, `ice`, `classic`, `noir`.  
- **Barra de iconos + contadores**: detecta tipos de mensaje (ICC, TOC, Comercio, etc.), muestra cuantos hay de cada tipo, y permite filtrar con un click.  
- **Sistema de reportes** vía comando o UI:
  - `/bpreport <jugador> <mensaje>` — agrega reporte para un jugador.  
  - `/bpshowreports <jugador>` — abre ventana con los reportes existentes. Si omites `<jugador>`, usa tu target actual.  
  - Los reportes se comparten por whisper del addon (no llenan el chat público).  
- **Configuración del usuario**:
  - Tiempo de expiración de mensajes (60, 90 o 120 segundos).  
  - Tema visual.  
  - Tipo de animación.  
  - Ventana de configuración movible, con botón de cerrar, y se cierra con `ESC`.

## 💬 Comandos

- `/bpreport <jugador> <mensaje>` — Añadir un reporte (Si no añades el mensaje, abrirá la ventana de reporte con ese jugador)
- `/bpshowreports <jugador>` — Ver los reportes de un jugador
- `/bpclearreports <jugador>` — Borrar todos tus reportes locales

- Si no especificas `<jugador>` en `/bpshowreports`, se intenta usar tu **target actual**.  
- Si usas `/bpreport` **sin argumentos**, abre la ventana de reporte vacía (útil para editar reportes manualmente).

## 📦 Instalación

1. Ve a la sección de releases y descarga el primer archivo zip.  
2. Descomprime su contenido dentro de tu carpeta de addons de WoW:  
- World of Warcraft/Interface/AddOns/ 

3. Abre el juego y asegúrate que BetterPosada esté activado en la lista de addons.

## 🛠️ Configuración

Para abrir la ventana de configuración puedes usar el botón que crea el addon, o asignarle un macro a tu conveniencia:

- Configura la animación, tema visual, y el tiempo de expiración.  
- Guarda los cambios con el botón **Guardar**, o cierra la ventana con la “X” o `ESC`.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Si encuentras errores, quieres sugerir mejoras o aportar nuevas funciones, sigue estos pasos:

1. Haz un **fork** del proyecto.  
2. Crea una **branch** con tu cambio.  
3. Envía un **pull request** explicando qué cambios realizaste.  
4. Espera revisión; tus cambios pueden ser integrados para que otros lo usen.
   
---


### ☕ Apoya el proyecto  
Si BetterPosada te ha sido útil y deseas apoyar el desarrollo:

**https://ko-fi.com/nibu1**

¡Gracias por usar BetterPosada! 🚪
