# 🚀 Instalación de Flutter - Pasos Detallados

## ⚠️ Importante
Necesitas permisos de administrador en tu Mac para instalar Flutter. Sigue estos pasos en tu Terminal.

---

## Paso 1: Instalar Homebrew (Si no lo tienes)

Abre una nueva ventana de **Terminal** (fuera de Claude Code) y ejecuta:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Qué pasará:**
- Te pedirá tu contraseña de administrador
- Instalará Homebrew (puede tardar 5-10 minutos)
- Al final te mostrará comandos para añadir Homebrew al PATH

**Si te muestra estos comandos al final, ejecútalos:**
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## Paso 2: Instalar Flutter

Una vez Homebrew esté instalado, ejecuta:

```bash
brew install --cask flutter
```

**Qué pasará:**
- Descargará Flutter (unos 500MB)
- Lo instalará automáticamente
- Tardará unos 5-10 minutos

---

## Paso 3: Verificar la Instalación

```bash
flutter doctor
```

**Qué verás:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[!] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[!] Chrome - develop for the web
[✓] VS Code (version x.x.x)
[✓] Connected device
```

**No te preocupes por las advertencias (!)** - son para desarrollo Android/Web que no necesitas ahora.

---

## Paso 4: Volver a Claude Code

Una vez Flutter esté instalado, vuelve aquí y dime:

```
"Flutter instalado"
```

Y continuaremos con la configuración del proyecto.

---

## 🆘 Si Tienes Problemas

### Error: "command not found: brew"
Después de instalar Homebrew, cierra y abre una nueva Terminal, o ejecuta:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Error: "Permission denied"
Asegúrate de tener permisos de administrador. Si no los tienes, pide ayuda a quien administre el Mac.

### Error al descargar Flutter
Verifica tu conexión a internet. Flutter pesa unos 500MB.

---

## 📍 ¿Por Qué Necesito Hacer Esto Manualmente?

Claude Code no puede ejecutar comandos que requieren:
- Contraseña de administrador
- Entrada interactiva del usuario
- Instalación de software del sistema

Por eso necesitas ejecutar estos comandos en tu Terminal normal.

---

## ⏱️ Tiempo Total Estimado

- **Instalar Homebrew**: 5-10 minutos
- **Instalar Flutter**: 5-10 minutos
- **Total**: 10-20 minutos

---

## ✅ Una Vez Completado

Cuando termines, regresa aquí y te ayudaré a:
1. ✅ Configurar el proyecto Flutter
2. ✅ Instalar las dependencias
3. ✅ Configurar los permisos
4. ✅ Ejecutar la app

---

**¡Vamos, casi lo tienes!** 🚀
