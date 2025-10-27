# Eventos de Hooks en Claude Code

Claude Code proporciona **9 eventos** donde puedes ejecutar hooks personalizados para automatizar y controlar tu flujo de trabajo.

## 📋 Resumen de Eventos

| # | Evento | Cuándo se Ejecuta | Puede Bloquear | Casos de Uso Principales |
|---|--------|-------------------|----------------|--------------------------|
| 1 | **SessionStart** | Al iniciar una nueva sesión | No | Configuración inicial, validaciones de entorno |
| 2 | **UserPromptSubmit** | Antes de enviar un prompt | Sí | Validar prompts, agregar contexto, detectar secretos |
| 3 | **PreToolUse** | Antes de ejecutar una herramienta | Sí | Linter, tests, validaciones de seguridad |
| 4 | **PostToolUse** | Después de ejecutar una herramienta | No | Formateo automático, logging, notificaciones |
| 5 | **Notification** | Cuando Claude envía notificaciones | No | Integración con Slack, email, logging |
| 6 | **Stop** | Antes de que Claude concluya respuesta | Sí | Revisión final, métricas, validaciones post-generación |
| 7 | **SubagentStop** | Antes de que un subagente concluya | Sí | Validar output de agentes, enriquecer respuestas |
| 8 | **PreCompact** | Antes de compactar conversación | Sí | Guardar historial, backup de contexto |
| 9 | **SessionEnd** | Cuando termina una sesión | No | Limpieza, reportes, estadísticas finales |

---

## 1. 🚀 SessionStart - Inicio de Sesión

**Cuándo se ejecuta:** Al iniciar una nueva sesión de Claude Code con el comando `claude`.

**Puede bloquear operaciones:** No

**Información recibida:**
```json
{
  "event": "SessionStart",
  "workingDirectory": "/path/to/project",
  "timestamp": "2025-01-22T10:30:00Z",
  "user": "username"
}
```

### Casos de Uso

#### ✅ Validaciones de Entorno
```javascript
// .claude/hooks/session-start.js
const fs = require('fs');
const { execSync } = require('child_process');

// Validar que el entorno está correctamente configurado
function validateEnvironment() {
    const checks = [];

    // 1. Verificar Node.js
    try {
        const nodeVersion = execSync('node --version', { encoding: 'utf-8' });
        checks.push(`✓ Node.js ${nodeVersion.trim()}`);
    } catch (e) {
        checks.push('✗ Node.js no instalado');
    }

    // 2. Verificar Git
    try {
        execSync('git --version', { encoding: 'utf-8' });
        checks.push('✓ Git instalado');
    } catch (e) {
        checks.push('✗ Git no instalado');
    }

    // 3. Verificar dependencias del proyecto
    if (fs.existsSync('package.json')) {
        if (fs.existsSync('node_modules')) {
            checks.push('✓ Dependencias instaladas');
        } else {
            checks.push('⚠️ Ejecuta: npm install');
        }
    }

    // 4. Verificar archivos de configuración
    if (!fs.existsSync('.env')) {
        checks.push('⚠️ Archivo .env no encontrado');
    } else {
        checks.push('✓ .env configurado');
    }

    return {
        action: 'notify',
        message: '🚀 Claude Code iniciado\n\n' + checks.join('\n')
    };
}

console.log(JSON.stringify(validateEnvironment()));
```

#### ✅ Mostrar Información del Proyecto
```javascript
// .claude/hooks/session-start.js
const fs = require('fs');

function showProjectInfo() {
    const info = ['📦 Información del Proyecto\n'];

    // Leer package.json
    if (fs.existsSync('package.json')) {
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
        info.push(`Nombre: ${pkg.name}`);
        info.push(`Versión: ${pkg.version}`);
        info.push(`Descripción: ${pkg.description || 'N/A'}`);
    }

    // Leer composer.json (Laravel)
    if (fs.existsSync('composer.json')) {
        const composer = JSON.parse(fs.readFileSync('composer.json', 'utf-8'));
        info.push(`Laravel: ${composer.require['laravel/framework'] || 'N/A'}`);
    }

    // Estado de Git
    try {
        const branch = execSync('git branch --show-current', { encoding: 'utf-8' }).trim();
        info.push(`\nBranch: ${branch}`);
    } catch (e) {
        info.push('\nGit: No es un repositorio');
    }

    return {
        action: 'notify',
        message: info.join('\n')
    };
}

console.log(JSON.stringify(showProjectInfo()));
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "session-start": {
      "command": "node .claude/hooks/session-start.js",
      "description": "Validar entorno al iniciar sesión"
    }
  }
}
```

---

## 2. 💬 UserPromptSubmit - Envío de Prompt

**Cuándo se ejecuta:** Inmediatamente antes de que el prompt del usuario sea enviado a Claude.

**Puede bloquear operaciones:** Sí (deny)

**Información recibida:**
```json
{
  "event": "UserPromptSubmit",
  "prompt": "El texto del prompt del usuario",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Validar y Enriquecer Prompts
Ya lo implementamos en `validate-prompt.js`. Otros ejemplos:

#### ✅ Detectar y Bloquear Secretos
```javascript
// .claude/hooks/user-prompt-submit.js
function detectSecrets(prompt) {
    const secretPatterns = [
        { pattern: /password\s*[:=]\s*['"].+['"]/i, name: 'Password' },
        { pattern: /api[_-]?key\s*[:=]\s*['"].+['"]/i, name: 'API Key' },
        { pattern: /secret\s*[:=]\s*['"].+['"]/i, name: 'Secret' },
        { pattern: /token\s*[:=]\s*['"].+['"]/i, name: 'Token' },
        { pattern: /sk-[a-zA-Z0-9]{32,}/, name: 'OpenAI API Key' },
        { pattern: /ghp_[a-zA-Z0-9]{36}/, name: 'GitHub Token' },
        { pattern: /\b\d{16}\b/, name: 'Credit Card Number' }
    ];

    for (const { pattern, name } of secretPatterns) {
        if (pattern.test(prompt)) {
            return {
                action: 'deny',
                message: `🔒 ALERTA DE SEGURIDAD: Posible ${name} detectado\n\n` +
                        'No incluyas secretos en prompts.\n' +
                        'Usa variables de entorno o archivos .env'
            };
        }
    }

    return { action: 'allow' };
}
```

#### ✅ Agregar Timestamp y Usuario
```javascript
// .claude/hooks/user-prompt-submit.js
const os = require('os');

function addMetadata(prompt) {
    const metadata = `
[METADATA]
Usuario: ${os.userInfo().username}
Timestamp: ${new Date().toISOString()}
Host: ${os.hostname()}

---

${prompt}
    `;

    return {
        action: 'modify',
        modifiedInput: metadata
    };
}
```

#### ✅ Traducir Prompts Automáticamente
```javascript
// .claude/hooks/user-prompt-submit.js
function autoTranslate(prompt) {
    // Si el prompt está en español, agregar instrucción
    const spanishPattern = /[áéíóúñ¿¡]/i;

    if (spanishPattern.test(prompt)) {
        const translatedPrompt = `
[INSTRUCCIÓN: El usuario escribió en español. Responde en español]

${prompt}
        `;

        return {
            action: 'modify',
            modifiedInput: translatedPrompt
        };
    }

    return { action: 'allow' };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "user-prompt-submit": {
      "command": "node .claude/hooks/user-prompt-submit.js",
      "description": "Validar y enriquecer prompts del usuario"
    }
  }
}
```

---

## 3. ⚙️ PreToolUse - Antes de Ejecutar Herramienta

**Cuándo se ejecuta:** Inmediatamente antes de que Claude ejecute una herramienta (Edit, Write, Bash, etc.)

**Puede bloquear operaciones:** Sí (deny)

**Información recibida:**
```json
{
  "event": "PreToolUse",
  "tool": "Edit",
  "parameters": {
    "file_path": "/path/to/file.js",
    "old_string": "const foo = 1",
    "new_string": "const foo = 2"
  },
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Ejecutar Linter Antes de Modificar
```javascript
// .claude/hooks/pre-tool-use.js
const { execSync } = require('child_process');
const fs = require('fs');

function validateWithLinter(data) {
    // Solo validar en operaciones Edit/Write
    if (!['Edit', 'Write'].includes(data.tool)) {
        return { action: 'allow' };
    }

    const filePath = data.parameters.file_path;

    // Solo archivos JavaScript/TypeScript
    if (!/\.(js|ts|jsx|tsx)$/.test(filePath)) {
        return { action: 'allow' };
    }

    try {
        // Ejecutar ESLint
        execSync(`npx eslint ${filePath}`, {
            encoding: 'utf-8',
            stdio: 'pipe'
        });

        return {
            action: 'allow',
            message: '✓ Linter: Sin errores'
        };
    } catch (error) {
        return {
            action: 'deny',
            message: '✗ Linter encontró errores:\n\n' + error.stdout
        };
    }
}

// Leer input
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    console.log(JSON.stringify(validateWithLinter(data)));
});
```

#### ✅ Prevenir Modificaciones en Archivos Críticos
```javascript
// .claude/hooks/pre-tool-use.js
function protectCriticalFiles(data) {
    if (!['Edit', 'Write', 'Delete'].includes(data.tool)) {
        return { action: 'allow' };
    }

    const filePath = data.parameters.file_path;
    const criticalFiles = [
        '.env',
        '.env.production',
        'package-lock.json',
        'composer.lock',
        'database/migrations/*'  // Usar glob pattern
    ];

    for (const pattern of criticalFiles) {
        if (filePath.includes(pattern)) {
            return {
                action: 'deny',
                message: `🔒 Archivo protegido: ${filePath}\n\n` +
                        'Este archivo es crítico y no puede ser modificado automáticamente.\n' +
                        'Edítalo manualmente si es necesario.'
            };
        }
    }

    return { action: 'allow' };
}
```

#### ✅ Ejecutar Tests Antes de Cambios Importantes
```javascript
// .claude/hooks/pre-tool-use.js
function runTestsForCriticalFiles(data) {
    if (!['Edit', 'Write'].includes(data.tool)) {
        return { action: 'allow' };
    }

    const filePath = data.parameters.file_path;

    // Solo para archivos en src/ o app/
    if (!/\/(src|app)\//.test(filePath)) {
        return { action: 'allow' };
    }

    try {
        // Ejecutar tests relacionados
        execSync('npm run test', {
            encoding: 'utf-8',
            stdio: 'pipe'
        });

        return {
            action: 'allow',
            message: '✓ Tests: Todos pasaron'
        };
    } catch (error) {
        return {
            action: 'deny',
            message: '✗ Tests fallaron:\n\n' +
                    'Corrige los tests antes de modificar el código.\n\n' +
                    error.stdout
        };
    }
}
```

#### ✅ Validar Comandos Bash Peligrosos
```javascript
// .claude/hooks/pre-tool-use.js
function validateBashCommands(data) {
    if (data.tool !== 'Bash') {
        return { action: 'allow' };
    }

    const command = data.parameters.command;

    // Comandos peligrosos
    const dangerousPatterns = [
        /rm\s+-rf\s+\//,           // rm -rf /
        /dd\s+if=/,                // dd commands
        /mkfs/,                    // format filesystem
        />\/dev\//,                // redirect to /dev/
        /curl.*\|\s*bash/,         // curl | bash
        /wget.*\|\s*bash/,         // wget | bash
        /chmod\s+777/              // chmod 777
    ];

    for (const pattern of dangerousPatterns) {
        if (pattern.test(command)) {
            return {
                action: 'deny',
                message: `⚠️ Comando peligroso bloqueado:\n\n${command}\n\n` +
                        'Este comando podría causar daños irreversibles.\n' +
                        'Ejecútalo manualmente si estás seguro.'
            };
        }
    }

    return { action: 'allow' };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "pre-tool-use": {
      "command": "node .claude/hooks/pre-tool-use.js",
      "description": "Validar operaciones antes de ejecutar herramientas"
    }
  }
}
```

---

## 4. ✅ PostToolUse - Después de Ejecutar Herramienta

**Cuándo se ejecuta:** Inmediatamente después de que Claude ejecute una herramienta exitosamente.

**Puede bloquear operaciones:** No (la operación ya se ejecutó)

**Información recibida:**
```json
{
  "event": "PostToolUse",
  "tool": "Edit",
  "parameters": {
    "file_path": "/path/to/file.js",
    "old_string": "const foo = 1",
    "new_string": "const foo = 2"
  },
  "result": "success",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Formatear Código Automáticamente
```javascript
// .claude/hooks/post-tool-use.js
const { execSync } = require('child_process');

function autoFormat(data) {
    // Solo para Edit/Write
    if (!['Edit', 'Write'].includes(data.tool)) {
        return { action: 'notify', message: '' };
    }

    const filePath = data.parameters.file_path;

    // JavaScript/TypeScript - usar Prettier
    if (/\.(js|ts|jsx|tsx)$/.test(filePath)) {
        try {
            execSync(`npx prettier --write ${filePath}`, {
                encoding: 'utf-8'
            });
            return {
                action: 'notify',
                message: `✓ Formateado: ${filePath}`
            };
        } catch (e) {
            return {
                action: 'notify',
                message: `⚠️ Error al formatear: ${filePath}`
            };
        }
    }

    // PHP - usar PHP CS Fixer
    if (/\.php$/.test(filePath)) {
        try {
            execSync(`vendor/bin/php-cs-fixer fix ${filePath}`, {
                encoding: 'utf-8'
            });
            return {
                action: 'notify',
                message: `✓ Formateado: ${filePath}`
            };
        } catch (e) {
            // Ignorar errores
        }
    }

    return { action: 'notify', message: '' };
}

// Leer input
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    console.log(JSON.stringify(autoFormat(data)));
});
```

#### ✅ Logging de Cambios
```javascript
// .claude/hooks/post-tool-use.js
const fs = require('fs');

function logChanges(data) {
    const logFile = '.claude/changes.log';

    const logEntry = {
        timestamp: new Date().toISOString(),
        tool: data.tool,
        file: data.parameters.file_path,
        result: data.result
    };

    // Agregar al log
    fs.appendFileSync(
        logFile,
        JSON.stringify(logEntry) + '\n'
    );

    return {
        action: 'notify',
        message: `📝 Cambio registrado en ${logFile}`
    };
}
```

#### ✅ Notificar al Equipo (Slack/Discord)
```javascript
// .claude/hooks/post-tool-use.js
const https = require('https');

function notifyTeam(data) {
    // Solo para cambios importantes
    if (!['Edit', 'Write'].includes(data.tool)) {
        return { action: 'notify', message: '' };
    }

    const webhookUrl = process.env.SLACK_WEBHOOK_URL;
    if (!webhookUrl) {
        return { action: 'notify', message: '' };
    }

    const message = {
        text: `🤖 Claude Code modificó: ${data.parameters.file_path}`
    };

    // Enviar a Slack
    const url = new URL(webhookUrl);
    const options = {
        hostname: url.hostname,
        path: url.pathname,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    const req = https.request(options);
    req.write(JSON.stringify(message));
    req.end();

    return {
        action: 'notify',
        message: '📢 Equipo notificado'
    };
}
```

#### ✅ Backup Automático
```javascript
// .claude/hooks/post-tool-use.js
const fs = require('fs');
const path = require('path');

function createBackup(data) {
    if (!['Edit', 'Write'].includes(data.tool)) {
        return { action: 'notify', message: '' };
    }

    const filePath = data.parameters.file_path;
    const backupDir = '.claude/backups';

    // Crear directorio si no existe
    if (!fs.existsSync(backupDir)) {
        fs.mkdirSync(backupDir, { recursive: true });
    }

    // Crear backup con timestamp
    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const backupPath = path.join(
        backupDir,
        `${path.basename(filePath)}.${timestamp}.bak`
    );

    try {
        fs.copyFileSync(filePath, backupPath);
        return {
            action: 'notify',
            message: `💾 Backup: ${backupPath}`
        };
    } catch (e) {
        return { action: 'notify', message: '' };
    }
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "post-tool-use": {
      "command": "node .claude/hooks/post-tool-use.js",
      "description": "Acciones después de ejecutar herramientas"
    }
  }
}
```

---

## 5. 🔔 Notification - Notificaciones

**Cuándo se ejecuta:** Cuando Claude envía una notificación al usuario.

**Puede bloquear operaciones:** No

**Información recibida:**
```json
{
  "event": "Notification",
  "type": "info|warning|error|success",
  "message": "Mensaje de la notificación",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Reenviar a Sistema de Logging Centralizado
```javascript
// .claude/hooks/notification.js
const fs = require('fs');

function centralizedLogging(data) {
    const logFile = '.claude/notifications.log';

    const logEntry = {
        timestamp: data.timestamp,
        type: data.type,
        message: data.message
    };

    fs.appendFileSync(
        logFile,
        JSON.stringify(logEntry) + '\n'
    );

    // Solo para errores, también enviar a error.log
    if (data.type === 'error') {
        fs.appendFileSync(
            '.claude/errors.log',
            `[${data.timestamp}] ${data.message}\n`
        );
    }

    return { action: 'allow' };
}

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    console.log(JSON.stringify(centralizedLogging(data)));
});
```

#### ✅ Filtrar Notificaciones Ruidosas
```javascript
// .claude/hooks/notification.js
function filterNotifications(data) {
    // Ignorar notificaciones de tipo "info" que son muy frecuentes
    const ignorePatterns = [
        /File read successfully/,
        /Cache hit/,
        /Token usage/
    ];

    if (data.type === 'info') {
        for (const pattern of ignorePatterns) {
            if (pattern.test(data.message)) {
                return {
                    action: 'suppress',  // No mostrar al usuario
                    message: ''
                };
            }
        }
    }

    return { action: 'allow' };  // Mostrar notificación
}
```

#### ✅ Enviar Errores a Sistema de Monitoreo
```javascript
// .claude/hooks/notification.js
const https = require('https');

function sendToSentry(data) {
    // Solo para errores
    if (data.type !== 'error') {
        return { action: 'allow' };
    }

    const sentryDSN = process.env.SENTRY_DSN;
    if (!sentryDSN) {
        return { action: 'allow' };
    }

    // Enviar a Sentry
    const payload = {
        message: data.message,
        level: 'error',
        timestamp: data.timestamp,
        tags: {
            source: 'claude-code'
        }
    };

    // ... código para enviar a Sentry API

    return { action: 'allow' };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "notification": {
      "command": "node .claude/hooks/notification.js",
      "description": "Procesar notificaciones de Claude"
    }
  }
}
```

---

## 6. ⏹️ Stop - Antes de Concluir Respuesta

**Cuándo se ejecuta:** Justo antes de que Claude termine de generar su respuesta al usuario.

**Puede bloquear operaciones:** Sí (puede modificar la respuesta)

**Información recibida:**
```json
{
  "event": "Stop",
  "response": "La respuesta completa que Claude está a punto de enviar",
  "tokensUsed": 1500,
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Validar Calidad de Respuesta
```javascript
// .claude/hooks/stop.js
function validateResponse(data) {
    const response = data.response;

    // Detectar respuestas incompletas
    if (response.endsWith('...') || response.includes('[incomplete]')) {
        return {
            action: 'deny',
            message: '⚠️ Respuesta incompleta detectada.\nPor favor, regenera con más contexto.'
        };
    }

    // Detectar código sin explicación
    const hasCode = /```/.test(response);
    const hasExplanation = response.split('```')[0].length > 50;

    if (hasCode && !hasExplanation) {
        return {
            action: 'modify',
            modifiedResponse: '💡 **Explicación del código:**\n\n' +
                             'Este código implementa la solución solicitada.\n\n' +
                             response
        };
    }

    return { action: 'allow' };
}
```

#### ✅ Agregar Footer Automático
```javascript
// .claude/hooks/stop.js
function addFooter(data) {
    const footer = `

---

📊 **Estadísticas:**
- Tokens usados: ${data.tokensUsed}
- Timestamp: ${data.timestamp}

💡 **Tip:** Usa /review para validar este código antes de commit
    `;

    return {
        action: 'modify',
        modifiedResponse: data.response + footer
    };
}
```

#### ✅ Calcular Métricas de Respuesta
```javascript
// .claude/hooks/stop.js
const fs = require('fs');

function trackMetrics(data) {
    const metrics = {
        timestamp: data.timestamp,
        tokens: data.tokensUsed,
        responseLength: data.response.length,
        hasCode: /```/.test(data.response),
        codeBlocks: (data.response.match(/```/g) || []).length / 2
    };

    // Guardar métricas
    fs.appendFileSync(
        '.claude/metrics.jsonl',
        JSON.stringify(metrics) + '\n'
    );

    return { action: 'allow' };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "stop": {
      "command": "node .claude/hooks/stop.js",
      "description": "Validar respuestas antes de enviarlas"
    }
  }
}
```

---

## 7. 🤖 SubagentStop - Antes de que Subagente Concluya

**Cuándo se ejecuta:** Justo antes de que un subagente (Task tool call) termine su ejecución.

**Puede bloquear operaciones:** Sí (puede modificar el resultado del agente)

**Información recibida:**
```json
{
  "event": "SubagentStop",
  "agentType": "general-purpose",
  "result": "Resultado del subagente",
  "tokensUsed": 500,
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Validar Output de Agentes
```javascript
// .claude/hooks/subagent-stop.js
function validateAgentOutput(data) {
    const result = data.result;

    // Validar que el agente completó la tarea
    if (result.includes('ERROR') || result.includes('FAILED')) {
        return {
            action: 'deny',
            message: `❌ El agente ${data.agentType} falló.\n\n` +
                    'Resultado:\n' + result
        };
    }

    // Validar que incluye archivos encontrados
    if (data.agentType === 'Explore' && !result.includes('Found:')) {
        return {
            action: 'deny',
            message: '⚠️ El agente de exploración no encontró resultados.'
        };
    }

    return { action: 'allow' };
}
```

#### ✅ Enriquecer Resultados de Agentes
```javascript
// .claude/hooks/subagent-stop.js
function enrichAgentResults(data) {
    const metadata = `

---
**Agente:** ${data.agentType}
**Tokens:** ${data.tokensUsed}
**Timestamp:** ${new Date(data.timestamp).toLocaleString()}
    `;

    return {
        action: 'modify',
        modifiedResult: data.result + metadata
    };
}
```

#### ✅ Logging de Uso de Agentes
```javascript
// .claude/hooks/subagent-stop.js
const fs = require('fs');

function logAgentUsage(data) {
    const log = {
        timestamp: data.timestamp,
        agent: data.agentType,
        tokens: data.tokensUsed,
        success: !data.result.includes('ERROR')
    };

    fs.appendFileSync(
        '.claude/agents.log',
        JSON.stringify(log) + '\n'
    );

    return { action: 'allow' };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "subagent-stop": {
      "command": "node .claude/hooks/subagent-stop.js",
      "description": "Validar outputs de subagentes"
    }
  }
}
```

---

## 8. 🗜️ PreCompact - Antes de Compactar Conversación

**Cuándo se ejecuta:** Justo antes de que Claude compacte el historial de conversación (/compact).

**Puede bloquear operaciones:** Sí (puede cancelar la compactación)

**Información recibida:**
```json
{
  "event": "PreCompact",
  "conversationLength": 15000,
  "messageCount": 50,
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Backup del Historial Completo
```javascript
// .claude/hooks/pre-compact.js
const fs = require('fs');
const path = require('path');

function backupConversation(data) {
    const backupDir = '.claude/conversation-backups';

    // Crear directorio si no existe
    if (!fs.existsSync(backupDir)) {
        fs.mkdirSync(backupDir, { recursive: true });
    }

    // Nombre del backup con timestamp
    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const backupFile = path.join(backupDir, `conversation-${timestamp}.json`);

    // Guardar metadata
    const backup = {
        timestamp: data.timestamp,
        messageCount: data.messageCount,
        conversationLength: data.conversationLength,
        note: 'Backup automático antes de compactación'
    };

    fs.writeFileSync(backupFile, JSON.stringify(backup, null, 2));

    return {
        action: 'allow',
        message: `💾 Backup guardado: ${backupFile}`
    };
}

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    console.log(JSON.stringify(backupConversation(data)));
});
```

#### ✅ Confirmar Compactación si es Grande
```javascript
// .claude/hooks/pre-compact.js
function confirmLargeCompaction(data) {
    // Si la conversación es muy grande, pedir confirmación
    if (data.messageCount > 100) {
        return {
            action: 'deny',
            message: `⚠️ Conversación muy grande (${data.messageCount} mensajes).\n\n` +
                    'Se perderá contexto valioso al compactar.\n' +
                    'Considera iniciar una nueva sesión con /clear en lugar de compactar.'
        };
    }

    return { action: 'allow' };
}
```

#### ✅ Extraer Decisiones Importantes Antes de Compactar
```javascript
// .claude/hooks/pre-compact.js
const fs = require('fs');

function extractDecisions(data) {
    // En un hook real, tendrías acceso al historial completo
    // Aquí simulamos extracción de decisiones importantes
    const decisions = `
# Decisiones Técnicas Antes de Compactación
Timestamp: ${data.timestamp}

[Este archivo preserva decisiones importantes del historial que está por compactarse]

## Arquitectura
- Decidido usar Repository Pattern para acceso a datos
- Implementar validaciones con Form Requests

## Testing
- Cobertura mínima: 80%
- Usar Pest para tests

## Deployment
- Deploy automático a staging en cada push a develop
    `;

    fs.appendFileSync('.claude/decisions.md', decisions);

    return {
        action: 'allow',
        message: '📝 Decisiones importantes guardadas en decisions.md'
    };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "pre-compact": {
      "command": "node .claude/hooks/pre-compact.js",
      "description": "Backup antes de compactar conversación"
    }
  }
}
```

---

## 9. 👋 SessionEnd - Fin de Sesión

**Cuándo se ejecuta:** Cuando la sesión de Claude Code está terminando (Ctrl+C, /exit, cierre).

**Puede bloquear operaciones:** No

**Información recibida:**
```json
{
  "event": "SessionEnd",
  "duration": 3600,
  "totalMessages": 45,
  "totalTokens": 25000,
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### Casos de Uso

#### ✅ Generar Reporte de Sesión
```javascript
// .claude/hooks/session-end.js
const fs = require('fs');

function generateSessionReport(data) {
    const report = `
# Reporte de Sesión Claude Code

**Fecha:** ${new Date(data.timestamp).toLocaleString()}
**Duración:** ${Math.round(data.duration / 60)} minutos
**Mensajes:** ${data.totalMessages}
**Tokens totales:** ${data.totalTokens.toLocaleString()}
**Costo estimado:** $${(data.totalTokens * 0.00003).toFixed(4)}

## Estadísticas
- Promedio de tokens por mensaje: ${Math.round(data.totalTokens / data.totalMessages)}
- Mensajes por minuto: ${(data.totalMessages / (data.duration / 60)).toFixed(2)}

---
Generado automáticamente por hook session-end
    `;

    const reportFile = `.claude/sessions/${data.timestamp.replace(/:/g, '-')}.md`;

    // Crear directorio si no existe
    const dir = '.claude/sessions';
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(reportFile, report);

    return {
        action: 'notify',
        message: `📊 Reporte de sesión guardado: ${reportFile}`
    };
}

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    console.log(JSON.stringify(generateSessionReport(data)));
});
```

#### ✅ Limpiar Archivos Temporales
```javascript
// .claude/hooks/session-end.js
const fs = require('fs');
const path = require('path');

function cleanup(data) {
    const cleanupTasks = [];

    // Limpiar backups antiguos (más de 7 días)
    const backupDir = '.claude/backups';
    if (fs.existsSync(backupDir)) {
        const files = fs.readdirSync(backupDir);
        const sevenDaysAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);

        files.forEach(file => {
            const filePath = path.join(backupDir, file);
            const stats = fs.statSync(filePath);

            if (stats.mtimeMs < sevenDaysAgo) {
                fs.unlinkSync(filePath);
                cleanupTasks.push(`Eliminado: ${file}`);
            }
        });
    }

    // Limpiar logs antiguos
    const logsToClean = [
        '.claude/validate-prompt.log',
        '.claude/changes.log'
    ];

    logsToClean.forEach(logFile => {
        if (fs.existsSync(logFile)) {
            const stats = fs.statSync(logFile);
            // Si el log es > 10MB, rotarlo
            if (stats.size > 10 * 1024 * 1024) {
                const rotatedName = `${logFile}.${Date.now()}.old`;
                fs.renameSync(logFile, rotatedName);
                cleanupTasks.push(`Log rotado: ${logFile}`);
            }
        }
    });

    return {
        action: 'notify',
        message: '🧹 Limpieza completada:\n' + cleanupTasks.join('\n')
    };
}
```

#### ✅ Enviar Estadísticas al Equipo
```javascript
// .claude/hooks/session-end.js
const https = require('https');

function sendStats(data) {
    const webhookUrl = process.env.SLACK_WEBHOOK_URL;
    if (!webhookUrl) {
        return { action: 'notify', message: '' };
    }

    const message = {
        text: `📊 Sesión de Claude Code finalizada`,
        blocks: [
            {
                type: 'section',
                text: {
                    type: 'mrkdwn',
                    text: `*Estadísticas de la sesión:*\n` +
                          `• Duración: ${Math.round(data.duration / 60)} minutos\n` +
                          `• Mensajes: ${data.totalMessages}\n` +
                          `• Tokens: ${data.totalTokens.toLocaleString()}`
                }
            }
        ]
    };

    // Enviar a Slack (código simplificado)
    const url = new URL(webhookUrl);
    const options = {
        hostname: url.hostname,
        path: url.pathname,
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    };

    const req = https.request(options);
    req.write(JSON.stringify(message));
    req.end();

    return {
        action: 'notify',
        message: '📢 Estadísticas enviadas al equipo'
    };
}
```

**Configuración en settings.json:**
```json
{
  "hooks": {
    "session-end": {
      "command": "node .claude/hooks/session-end.js",
      "description": "Generar reporte al finalizar sesión"
    }
  }
}
```

---

## 🔗 Configuración Completa de Múltiples Hooks

Ejemplo de configuración con todos los 9 eventos de hooks:

```json
{
  "hooks": {
    "session-start": {
      "command": "node .claude/hooks/session-start.js",
      "description": "Validar entorno al iniciar"
    },
    "user-prompt-submit": {
      "command": "node .claude/hooks/user-prompt-submit.js",
      "description": "Validar y enriquecer prompts"
    },
    "pre-tool-use": {
      "command": "node .claude/hooks/pre-tool-use.js",
      "description": "Validar antes de ejecutar herramientas"
    },
    "post-tool-use": {
      "command": "node .claude/hooks/post-tool-use.js",
      "description": "Formatear código automáticamente"
    },
    "notification": {
      "command": "node .claude/hooks/notification.js",
      "description": "Logging centralizado de notificaciones"
    },
    "stop": {
      "command": "node .claude/hooks/stop.js",
      "description": "Validar respuestas antes de enviarlas"
    },
    "subagent-stop": {
      "command": "node .claude/hooks/subagent-stop.js",
      "description": "Validar outputs de subagentes"
    },
    "pre-compact": {
      "command": "node .claude/hooks/pre-compact.js",
      "description": "Backup antes de compactar conversación"
    },
    "session-end": {
      "command": "node .claude/hooks/session-end.js",
      "description": "Generar reporte al finalizar sesión"
    }
  }
}
```

---

## 📊 Comparación de Eventos

### Cuándo Usar Cada Hook

| Necesitas... | Usa este Hook |
|-------------|---------------|
| Validar entorno al inicio | **SessionStart** |
| Validar prompts del usuario | **UserPromptSubmit** |
| Agregar contexto automático | **UserPromptSubmit** |
| Ejecutar linter antes de cambios | **PreToolUse** |
| Bloquear comandos peligrosos | **PreToolUse** |
| Proteger archivos críticos | **PreToolUse** |
| Formatear código automáticamente | **PostToolUse** |
| Crear backups de archivos | **PostToolUse** |
| Logging centralizado | **Notification** |
| Notificar al equipo | **PostToolUse** o **Notification** |
| Validar calidad de respuestas | **Stop** |
| Agregar footer automático | **Stop** |
| Calcular métricas de tokens | **Stop** |
| Validar output de agentes | **SubagentStop** |
| Enriquecer resultados de agentes | **SubagentStop** |
| Backup antes de compactar | **PreCompact** |
| Prevenir pérdida de contexto | **PreCompact** |
| Generar reportes de sesión | **SessionEnd** |
| Limpiar archivos temporales | **SessionEnd** |
| Enviar estadísticas al equipo | **SessionEnd** |

---

## 🎯 Mejores Prácticas

### 1. Mantén los Hooks Rápidos
Los hooks bloquean operaciones. Deben ejecutarse en < 2 segundos.

```javascript
// ❌ MAL: Operación lenta
function slowHook(data) {
    // Proceso que toma 10 segundos
    heavyComputation();
}

// ✅ BIEN: Ejecutar en background si es necesario
function fastHook(data) {
    // Validación rápida
    if (quickCheck()) {
        // Operación pesada en background
        fork('heavy-process.js');
    }
    return { action: 'allow' };
}
```

### 2. Manejo de Errores Robusto
```javascript
function safeHook(data) {
    try {
        return validateData(data);
    } catch (error) {
        // Log el error pero no bloquear
        logError(error);
        return { action: 'allow' };
    }
}
```

### 3. Configuración por Entorno
```javascript
// Comportamiento diferente en dev vs prod
const isDevelopment = process.env.NODE_ENV === 'development';

if (isDevelopment) {
    // Más permisivo en desarrollo
    return { action: 'allow' };
} else {
    // Más estricto en producción
    return strictValidation(data);
}
```

---

## 📚 Recursos Adicionales

- [Documentación oficial de Hooks](https://docs.claude.com/claude-code/hooks)
- [Ejemplos de hooks en GitHub](https://github.com/anthropics/claude-code-examples)
- [Comunidad de Claude Code](https://discord.gg/claude-code)
