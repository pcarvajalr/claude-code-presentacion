# 🎣 Resumen Rápido de Hooks en Claude Code

## 🔄 Ciclo de Vida de una Sesión

```
┌─────────────────────────────────────────────────────────────┐
│                     INICIO DE SESIÓN                        │
│  1. SessionStart ──> Validar entorno, configuración        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    INTERACCIÓN USUARIO                      │
│  2. UserPromptSubmit ──> Usuario envía prompt              │
│     ├─ Validar prompt                                       │
│     ├─ Detectar secretos                                    │
│     └─ Agregar contexto                                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   PROCESAMIENTO CLAUDE                      │
│  ┌─ Claude puede usar AGENTES ─────────────────────┐       │
│  │  7. SubagentStop ──> Validar outputs de agente  │       │
│  └──────────────────────────────────────────────────┘       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   EJECUCIÓN DE HERRAMIENTAS                 │
│  3. PreToolUse ──> Antes de Edit/Write/Bash                │
│     ├─ Ejecutar linter                                      │
│     ├─ Validar permisos                                     │
│     └─ Bloquear si falla                                    │
│                                                              │
│     ⚙️ Herramienta se ejecuta (Edit, Write, Bash, etc.)    │
│                                                              │
│  4. PostToolUse ──> Después de ejecutar                    │
│     ├─ Formatear código                                     │
│     ├─ Crear backups                                        │
│     └─ Notificar equipo                                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    RESPUESTA CLAUDE                         │
│  6. Stop ──> Antes de mostrar respuesta al usuario         │
│     ├─ Validar calidad                                      │
│     ├─ Agregar footer                                       │
│     └─ Calcular métricas                                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    NOTIFICACIONES                           │
│  5. Notification ──> Durante toda la sesión                │
│     ├─ Logging centralizado                                 │
│     ├─ Filtrar notificaciones                               │
│     └─ Enviar a sistema de monitoreo                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              OPERACIONES ESPECIALES                         │
│  8. PreCompact ──> Antes de /compact                       │
│     ├─ Backup del historial                                 │
│     ├─ Extraer decisiones importantes                       │
│     └─ Confirmar si es conversación grande                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     FIN DE SESIÓN                           │
│  9. SessionEnd ──> Al cerrar Claude Code                   │
│     ├─ Generar reporte de sesión                           │
│     ├─ Limpiar archivos temporales                         │
│     ├─ Enviar estadísticas                                 │
│     └─ Guardar métricas                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Tabla Comparativa de los 9 Hooks

| # | Hook | Momento | Bloquea | Uso Principal |
|---|------|---------|---------|---------------|
| 1️⃣ | **SessionStart** | Al iniciar `claude` | ❌ No | Validar entorno, mostrar info del proyecto |
| 2️⃣ | **UserPromptSubmit** | Antes de enviar prompt | ✅ Sí | Validar prompts, detectar secretos, agregar contexto |
| 3️⃣ | **PreToolUse** | Antes de Edit/Write/Bash | ✅ Sí | Linter, tests, proteger archivos críticos |
| 4️⃣ | **PostToolUse** | Después de Edit/Write/Bash | ❌ No | Formatear código, backups, notificaciones |
| 5️⃣ | **Notification** | Durante toda la sesión | ❌ No | Logging, filtrar ruido, integración Sentry |
| 6️⃣ | **Stop** | Antes de mostrar respuesta | ✅ Sí | Validar calidad, agregar footer, métricas |
| 7️⃣ | **SubagentStop** | Al terminar agente | ✅ Sí | Validar outputs de Task tool, enriquecer |
| 8️⃣ | **PreCompact** | Antes de `/compact` | ✅ Sí | Backup historial, extraer decisiones |
| 9️⃣ | **SessionEnd** | Al cerrar sesión | ❌ No | Reportes, limpieza, estadísticas finales |

---

## 🎯 Casos de Uso por Necesidad

### 🔒 Seguridad
```
UserPromptSubmit  ──> Detectar secretos en prompts
PreToolUse        ──> Bloquear comandos peligrosos
PreToolUse        ──> Proteger archivos .env, production
```

### ✅ Calidad de Código
```
PreToolUse   ──> Ejecutar linter antes de cambios
PreToolUse   ──> Ejecutar tests automáticamente
PostToolUse  ──> Formatear código con Prettier/PHP-CS-Fixer
Stop         ──> Validar que respuestas incluyen explicaciones
```

### 📊 Métricas y Reporting
```
Stop        ──> Calcular tokens por respuesta
SessionEnd  ──> Generar reporte completo de sesión
Notification ──> Logging centralizado
```

### 🤝 Colaboración
```
UserPromptSubmit  ──> Agregar contexto de estándares del equipo
PostToolUse       ──> Notificar cambios en Slack
SessionEnd        ──> Enviar estadísticas al equipo
```

### 💾 Backup y Recuperación
```
PostToolUse  ──> Backup automático de archivos modificados
PreCompact   ──> Backup completo antes de compactar
SessionEnd   ──> Guardar decisiones importantes
```

### 🧹 Mantenimiento
```
SessionEnd  ──> Limpiar backups antiguos (>7 días)
SessionEnd  ──> Rotar logs grandes (>10MB)
```

---

## ⚡ Flujo de Ejemplo Completo

```javascript
// Usuario inicia Claude Code
claude
  └─> SessionStart
        ├─ ✓ Node.js v18.0.0 detectado
        ├─ ✓ Git instalado
        └─ ✓ .env configurado

// Usuario escribe prompt
> Crea un endpoint API REST para productos
  └─> UserPromptSubmit
        ├─ ✓ Prompt validado (>10 chars)
        ├─ ✓ Sin secretos detectados
        └─ ✓ Contexto Laravel agregado automáticamente

// Claude genera código y lo va a escribir
Write(ProductController.php)
  └─> PreToolUse
        ├─ Ejecutando linter...
        ├─ ✓ PSR-12 compliant
        └─ ✓ Permitido continuar

// Archivo escrito exitosamente
  └─> PostToolUse
        ├─ ✓ Formateado con php-cs-fixer
        ├─ 💾 Backup creado
        └─ 📢 Equipo notificado en Slack

// Claude termina su respuesta
  └─> Stop
        ├─ ✓ Respuesta completa (no truncada)
        ├─ Tokens usados: 1,234
        └─ 💡 Footer con tips agregado

// Usuario ejecuta /compact
/compact
  └─> PreCompact
        ├─ 💾 Backup: conversation-2025-01-22.json
        ├─ 📝 Decisiones guardadas en decisions.md
        └─ ✓ Compactación permitida

// Usuario cierra Claude Code
Ctrl+C
  └─> SessionEnd
        ├─ 📊 Reporte generado: sessions/2025-01-22.md
        ├─ 🧹 3 backups antiguos eliminados
        ├─ 📈 Estadísticas: 45 mensajes, 25k tokens, $0.75
        └─ 👋 Sesión finalizada
```

---

## 🚀 Quick Start

### 1. Configuración Mínima (Solo lo esencial)
```json
{
  "hooks": {
    "user-prompt-submit": {
      "command": "node .claude/hooks/validate-prompt.js",
      "description": "Validar prompts y detectar secretos"
    },
    "pre-tool-use": {
      "command": "node .claude/hooks/pre-tool-use.js",
      "description": "Ejecutar linter antes de cambios"
    },
    "post-tool-use": {
      "command": "node .claude/hooks/post-tool-use.js",
      "description": "Formatear código automáticamente"
    }
  }
}
```

### 2. Configuración Completa (Todos los hooks)
```json
{
  "hooks": {
    "session-start": {
      "command": "node .claude/hooks/session-start.js",
      "description": "Validar entorno"
    },
    "user-prompt-submit": {
      "command": "node .claude/hooks/user-prompt-submit.js",
      "description": "Validar prompts"
    },
    "pre-tool-use": {
      "command": "node .claude/hooks/pre-tool-use.js",
      "description": "Linter y tests"
    },
    "post-tool-use": {
      "command": "node .claude/hooks/post-tool-use.js",
      "description": "Formateo automático"
    },
    "notification": {
      "command": "node .claude/hooks/notification.js",
      "description": "Logging centralizado"
    },
    "stop": {
      "command": "node .claude/hooks/stop.js",
      "description": "Validar respuestas"
    },
    "subagent-stop": {
      "command": "node .claude/hooks/subagent-stop.js",
      "description": "Validar agentes"
    },
    "pre-compact": {
      "command": "node .claude/hooks/pre-compact.js",
      "description": "Backup antes de compactar"
    },
    "session-end": {
      "command": "node .claude/hooks/session-end.js",
      "description": "Reportes finales"
    }
  }
}
```

---

## 📚 Archivos de Referencia

- **Guía completa**: `.claude/hooks/EVENTOS-HOOKS.md`
- **Hook de ejemplo**: `.claude/hooks/validate-prompt.js`
- **README**: `.claude/hooks/README.md`
- **Este resumen**: `.claude/hooks/HOOKS-RESUMEN.md`

---

## 💡 Tips

1. **Empieza simple**: Usa solo 2-3 hooks inicialmente
2. **Prueba hooks manualmente** antes de activarlos
3. **Mantén hooks rápidos**: < 2 segundos
4. **Logging para debug**: Guarda logs en `.claude/hooks/*.log`
5. **Comparte con el equipo**: Versiona `.claude/` en git

---

**🎣 Happy Hooking!**
