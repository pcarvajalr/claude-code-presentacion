# PDF Generation Troubleshooting Guide

Extended troubleshooting reference for common PDF generation issues.

## Installation Issues

### Pandoc Not Found

**Symptoms:**
```
'pandoc' is not recognized as an internal or external command
```

**Solutions:**

**Windows:**
```powershell
# Option 1: winget
winget install pandoc

# Option 2: Chocolatey
choco install pandoc

# Option 3: Scoop
scoop install pandoc
```

**Verify installation:**
```bash
pandoc --version
```

### wkhtmltopdf Not Found

**Symptoms:**
```
'wkhtmltopdf' is not recognized as an internal or external command
```

**Solutions:**

**Windows:**
```powershell
# Option 1: winget
winget install wkhtmltopdf

# Option 2: Chocolatey
choco install wkhtmltopdf
```

**After installation:**
- Restart terminal/PowerShell
- Verify: `wkhtmltopdf --version`

### Playwright/Node.js Issues

**Symptoms:**
```
Cannot find module 'playwright'
```

**Solutions:**
```bash
# Install Playwright
npm install -D playwright

# Install browser binaries
npx playwright install chromium

# Or install globally
npm install -g playwright
npx playwright install
```

## Conversion Issues

### Images Not Displaying in PDF

**Problem:** Images referenced in markdown don't appear in generated PDF

**Causes & Solutions:**

**1. Relative Path Issues**
```bash
# Bad: Relative path from working directory
![Image](images/logo.png)

# Good: Absolute path
![Image](C:/projects/myproject/images/logo.png)

# Good: Relative to markdown file (if in same directory structure)
![Image](./images/logo.png)
```

**2. Image Format Not Supported**
- Use PNG, JPEG, or GIF formats
- Convert SVG to PNG if needed: `convert image.svg image.png`

**3. File Permissions**
```powershell
# Check file permissions (PowerShell)
Get-Acl .\images\logo.png | Format-List
```

**4. Use --resource-path option**
```bash
pandoc document.md -o document.pdf --resource-path=.:./images
```

### Fonts Not Rendering

**Problem:** Custom fonts or Unicode characters display incorrectly

**Solutions:**

**1. Use XeLaTeX for Unicode support:**
```bash
pandoc document.md -o document.pdf --pdf-engine=xelatex
```

**2. Specify font explicitly:**
```bash
pandoc document.md -o document.pdf \
  --pdf-engine=xelatex \
  --variable mainfont="Arial" \
  --variable monofont="Consolas"
```

**3. Install required fonts:**
- Windows: Copy font files to `C:\Windows\Fonts`
- Or use Font Settings in Windows Settings

**4. List available fonts:**
```bash
fc-list  # On systems with fontconfig
```

### Large PDF File Size

**Problem:** Generated PDF is unnecessarily large

**Solutions:**

**1. Compress images before conversion:**
```bash
# Using ImageMagick
magick convert input.jpg -quality 85 -resize 1920x1080\> output.jpg
```

**2. Use PDF compression tools after generation:**
```bash
# Using Ghostscript
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=output-compressed.pdf input.pdf
```

**3. Reduce image resolution in markdown:**
```markdown
![Image](image.png){width=50%}
```

### CSS Styling Not Applied

**Problem:** Custom CSS styles don't appear in PDF

**Solutions:**

**1. Use correct PDF engine:**
```bash
# wkhtmltopdf supports CSS better than LaTeX engines
pandoc document.md -o document.pdf \
  --pdf-engine=wkhtmltopdf \
  --css=styles.css
```

**2. Use print media type:**
```bash
wkhtmltopdf --print-media-type input.html output.pdf
```

**3. Inline CSS in HTML:**
Instead of external CSS, use `<style>` tags in HTML header

**4. Use pandoc variables for LaTeX:**
```bash
pandoc document.md -o document.pdf \
  --variable colorlinks=true \
  --variable linkcolor=blue
```

### JavaScript Not Executing (Presentations)

**Problem:** Dynamic content from JavaScript doesn't render

**Solutions:**

**1. Use Playwright instead of wkhtmltopdf:**
```bash
node .claude/skills/pdf-generator/scripts/html-to-pdf.js \
  presentation.html output.pdf --wait 5000
```

**2. Increase wait time with wkhtmltopdf:**
```bash
wkhtmltopdf --javascript-delay 5000 \
  --no-stop-slow-scripts \
  input.html output.pdf
```

**3. Use print mode for reveal.js:**
```
http://localhost:8000/presentation.html?print-pdf
```

## LaTeX Errors

### Missing LaTeX Packages

**Symptoms:**
```
! LaTeX Error: File `package.sty' not found
```

**Solutions:**

**1. Install full LaTeX distribution:**
- Windows: Install MiKTeX or TeX Live
- MiKTeX auto-installs packages on demand

**2. Manually install package:**
```bash
# Using MiKTeX Package Manager
mpm --install=package-name
```

**3. Use different template:**
```bash
pandoc document.md -o document.pdf --template=simple.tex
```

### LaTeX Compilation Errors

**Symptoms:**
```
Error producing PDF
```

**Solutions:**

**1. Enable verbose output:**
```bash
pandoc document.md -o document.pdf --verbose
```

**2. Check intermediate .tex file:**
```bash
# Generate .tex file instead of PDF
pandoc document.md -o document.tex

# Review the .tex file for issues
```

**3. Use simpler PDF engine:**
```bash
# Try wkhtmltopdf instead of LaTeX
pandoc document.md -o document.pdf --pdf-engine=wkhtmltopdf
```

## Encoding Issues

### Special Characters Garbled

**Problem:** Accents, symbols, or non-ASCII characters display incorrectly

**Solutions:**

**1. Ensure source file is UTF-8:**
```powershell
# Check file encoding (PowerShell)
Get-Content document.md | Format-Hex | Select-Object -First 5
```

**2. Force UTF-8 input:**
```bash
pandoc document.md -o document.pdf --from=markdown+smart
```

**3. Use XeLaTeX for full Unicode:**
```bash
pandoc document.md -o document.pdf --pdf-engine=xelatex
```

## Performance Issues

### Slow Conversion

**Problem:** PDF generation takes too long

**Solutions:**

**1. Optimize images first:**
- Reduce resolution
- Compress before conversion

**2. Use faster PDF engine:**
```bash
# wkhtmltopdf is generally faster than LaTeX
pandoc document.md -o document.pdf --pdf-engine=wkhtmltopdf
```

**3. Batch process efficiently:**
```bash
# Use parallel processing
find . -name "*.md" -print0 | xargs -0 -P 4 -I {} \
  pandoc {} -o {}.pdf
```

## Windows-Specific Issues

### Path Issues

**Problem:** Paths with spaces cause errors

**Solutions:**

**1. Use quotes:**
```powershell
pandoc "My Document.md" -o "My Document.pdf"
```

**2. Use PowerShell escaping:**
```powershell
pandoc .\My` Document.md -o .\My` Document.pdf
```

### Permission Denied

**Problem:** Cannot write output file

**Solutions:**

**1. Run as Administrator (if needed)**

**2. Check file is not open in another program**

**3. Verify write permissions:**
```powershell
Get-Acl . | Format-List
```

## Debug Workflow

When encountering issues:

1. **Verify tool installation:**
   ```bash
   pandoc --version
   wkhtmltopdf --version
   node --version
   ```

2. **Test with minimal example:**
   ```bash
   echo "# Test" > test.md
   pandoc test.md -o test.pdf
   ```

3. **Enable verbose output:**
   ```bash
   pandoc document.md -o document.pdf --verbose
   ```

4. **Check intermediate files:**
   ```bash
   pandoc document.md -o document.tex  # Review generated LaTeX
   ```

5. **Try alternative method:**
   - If pandoc fails, try wkhtmltopdf
   - If wkhtmltopdf fails, try Playwright
   - Convert to HTML first, then to PDF

## Getting Help

If issues persist:

1. Check pandoc documentation: https://pandoc.org/MANUAL.html
2. Review error messages carefully
3. Search for specific error messages online
4. Check GitHub issues for the tool you're using
5. Verify all prerequisites are installed correctly
