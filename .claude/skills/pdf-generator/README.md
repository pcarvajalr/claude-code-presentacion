# PDF Generator Skill

Un skill completo para Claude Code que permite generar archivos PDF desde markdown, HTML y presentaciones.

## ¿Qué es este skill?

Este skill proporciona a Claude la capacidad de generar PDFs profesionales desde diversos formatos de origen. Incluye:

- **Workflows documentados** para diferentes tipos de conversión
- **Scripts automatizados** para conversiones complejas
- **Referencias completas** de opciones y troubleshooting
- **Plantillas profesionales** para reportes y documentos

## Contenido del Skill

```
pdf-generator/
├── SKILL.md                          # Skill principal con workflows
├── scripts/
│   ├── html-to-pdf.js               # Script Node.js con Playwright
│   └── convert-presentation.ps1     # Script PowerShell para batch
├── references/
│   ├── pandoc-options.md            # Referencia completa de pandoc
│   └── troubleshooting.md           # Guía de solución de problemas
└── assets/
    ├── report-template.tex          # Plantilla LaTeX profesional
    └── css/
        └── pdf-styles.css           # Estilos CSS para PDFs
```

## Instalación

### Opción 1: Skill de Proyecto
Copiar la carpeta `pdf-generator` a `.claude/skills/` en tu proyecto:

```bash
# El skill ya está en este proyecto
.claude/skills/pdf-generator/
```

### Opción 2: Skill Global
Copiar la carpeta a tu directorio global de skills:

```bash
# Windows
C:\Users\<usuario>\.claude\skills\pdf-generator\

# Linux/Mac
~/.claude/skills/pdf-generator/
```

### Opción 3: Desde archivo zip
Descomprimir `pdf-generator.zip` en la ubicación deseada.

## Prerequisitos

Para usar este skill, necesitas instalar al menos una de estas herramientas:

### pandoc (Recomendado para markdown)
```bash
# Windows
winget install pandoc
# o
choco install pandoc
```

### wkhtmltopdf (Recomendado para HTML)
```bash
# Windows
winget install wkhtmltopdf
# o
choco install wkhtmltopdf
```

### Playwright (Para presentaciones dinámicas)
```bash
npm install -D playwright
npx playwright install chromium
```

## Cómo usar el skill

Una vez instalado, el skill se activa automáticamente cuando:

- Pides generar un PDF
- Mencionas convertir documentación a PDF
- Solicitas convertir presentaciones HTML a PDF
- Pides crear reportes en PDF

### Ejemplos de uso

**Ejemplo 1: Convertir markdown a PDF**
```
Usuario: "Convierte el README.md a PDF"

Claude usará el skill pdf-generator y ejecutará:
pandoc README.md -o README.pdf --variable geometry:margin=1in
```

**Ejemplo 2: Convertir presentación HTML a PDF**
```
Usuario: "Genera un PDF de la presentación modulo-1-fundamentos.html"

Claude usará el skill y ejecutará:
node .claude/skills/pdf-generator/scripts/html-to-pdf.js \
  modulo-1-fundamentos.html \
  modulo-1-fundamentos.pdf
```

**Ejemplo 3: Generar reporte con plantilla**
```
Usuario: "Crea un PDF del reporte de ventas con formato profesional"

Claude usará el skill y ejecutará:
pandoc ventas.md -o ventas.pdf \
  --template=.claude/skills/pdf-generator/assets/report-template.tex \
  --pdf-engine=xelatex
```

## Estructura del Skill

### SKILL.md
El archivo principal que contiene:
- 4 workflows principales (Markdown, HTML, Presentaciones, Batch)
- Árbol de decisión para elegir la herramienta correcta
- Mejores prácticas y troubleshooting básico
- Ejemplos de uso

### Scripts

**html-to-pdf.js**
- Script Node.js usando Playwright
- Ideal para presentaciones con JavaScript
- Soporta orientación landscape/portrait
- Maneja contenido dinámico

**convert-presentation.ps1**
- Script PowerShell para Windows
- Conversión batch de múltiples archivos
- Usa wkhtmltopdf
- Ideal para procesamiento masivo

### Referencias

**pandoc-options.md**
- Guía completa de opciones de pandoc
- Ejemplos para diferentes tipos de documentos
- Configuración de márgenes, fuentes, estilos
- Plantillas y motores PDF

**troubleshooting.md**
- Problemas comunes y soluciones
- Errores de instalación
- Problemas de codificación
- Issues específicos de Windows

### Assets

**report-template.tex**
- Plantilla LaTeX profesional
- Configuración de márgenes y tipografía
- Estilos para código y tablas
- Headers y footers personalizables

**css/pdf-styles.css**
- Estilos CSS optimizados para PDF
- Configuración de page breaks
- Estilos para tablas y código
- Diseño responsive para impresión

## Prueba del Skill

Para probar que el skill funciona correctamente:

1. **Verifica que Claude lo detecta:**
   ```
   "¿Tienes algún skill para generar PDFs?"
   ```
   Claude debería mencionar el skill pdf-generator.

2. **Prueba una conversión simple:**
   ```
   "Convierte este archivo markdown a PDF"
   ```
   Claude debería usar el skill automáticamente.

3. **Verifica que accede a los recursos:**
   ```
   "¿Qué opciones de pandoc recomiendas para un reporte?"
   ```
   Claude debería referenciar `references/pandoc-options.md`.

## Ejemplo Real: Convertir Presentación del Proyecto

Este proyecto contiene presentaciones HTML. Para convertirlas a PDF:

```bash
# Usando el script de PowerShell (batch)
.\.claude\skills\pdf-generator\scripts\convert-presentation.ps1 `
  -InputPath . `
  -OutputPath .\pdfs\ `
  -Batch

# O usando wkhtmltopdf directamente
wkhtmltopdf --enable-local-file-access `
  --page-size A4 `
  --orientation Landscape `
  --print-media-type `
  modulo-1-fundamentos.html `
  modulo-1-fundamentos.pdf
```

## Beneficios del Skill

### Para Claude
- ✅ Conocimiento especializado en generación de PDFs
- ✅ Scripts reutilizables que no necesita reescribir
- ✅ Referencias detalladas para casos complejos
- ✅ Troubleshooting estructurado

### Para el Usuario
- ✅ Conversiones rápidas y consistentes
- ✅ Calidad profesional en los PDFs
- ✅ Automatización de tareas repetitivas
- ✅ Soporte para múltiples formatos

## Personalización

Puedes personalizar el skill modificando:

- **SKILL.md**: Agregar workflows específicos de tu proyecto
- **Plantillas**: Modificar `report-template.tex` con tu branding
- **CSS**: Ajustar `pdf-styles.css` para tu estilo corporativo
- **Scripts**: Extender los scripts con opciones personalizadas

## Versionamiento

**Versión actual**: 1.0.0
**Creado**: 2024-10-28
**Licencia**: Uso libre en proyectos Claude Code

## Contribuciones

Este skill fue creado siguiendo las mejores prácticas de `skill-creator`.

Mejoras futuras sugeridas:
- [ ] Soporte para conversión de DOCX a PDF
- [ ] Integración con servicios cloud de conversión
- [ ] Plantillas adicionales (presentaciones, informes académicos)
- [ ] Compresión automática de PDFs generados

## Recursos Adicionales

- [Documentación de pandoc](https://pandoc.org/MANUAL.html)
- [wkhtmltopdf Documentation](https://wkhtmltopdf.org/usage/wkhtmltopdf.txt)
- [Playwright PDF API](https://playwright.dev/docs/api/class-page#page-pdf)
- [Skill Creator Guide](.claude/skills/skill-creator/SKILL.md)

---

**Creado con Claude Code usando el skill-creator** 🤖
