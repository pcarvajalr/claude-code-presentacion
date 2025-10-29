# Pandoc Options Reference

Comprehensive guide to pandoc command-line options for PDF generation.

## Basic Usage

```bash
pandoc [OPTIONS] -o output.pdf input.md
```

## Common PDF Options

### Page Layout

**Margins:**
```bash
--variable geometry:margin=1in
--variable geometry:top=1in
--variable geometry:bottom=1in
--variable geometry:left=1.25in
--variable geometry:right=1.25in
```

**Paper Size:**
```bash
--variable papersize=a4
--variable papersize=letter
--variable papersize=legal
```

**Font Size:**
```bash
--variable fontsize=10pt
--variable fontsize=12pt
--variable fontsize=14pt
```

**Orientation:**
```bash
--variable classoption=landscape
```

### Document Structure

**Table of Contents:**
```bash
--toc                     # Enable table of contents
--toc-depth=2             # Depth of headings to include
--number-sections         # Number section headings
```

**Metadata:**
```bash
--variable title="Document Title"
--variable author="Author Name"
--variable date="2024-10-28"
--variable date="\today"  # Use current date
```

### PDF Engines

Pandoc supports multiple PDF engines with different capabilities:

**wkhtmltopdf** (HTML-based, good for styling):
```bash
--pdf-engine=wkhtmltopdf
```

**xelatex** (Best Unicode/font support):
```bash
--pdf-engine=xelatex
```

**pdflatex** (Standard LaTeX):
```bash
--pdf-engine=pdflatex
```

**lualatex** (Modern LaTeX with Lua):
```bash
--pdf-engine=lualatex
```

### Styling and Formatting

**Syntax Highlighting:**
```bash
--highlight-style=tango
--highlight-style=pygments
--highlight-style=kate
--highlight-style=monochrome
```

**Custom CSS (with wkhtmltopdf):**
```bash
--css=style.css
```

**Line Spacing:**
```bash
--variable linestretch=1.5
```

**Code Block Options:**
```bash
--listings                # Use listings package for code
--variable monofont="Courier New"
```

### Advanced Options

**Templates:**
```bash
--template=template.tex
```

**Include in Header:**
```bash
--include-in-header=header.tex
```

**Include Before Body:**
```bash
--include-before-body=before.tex
```

**Include After Body:**
```bash
--include-after-body=after.tex
```

**PDF Metadata:**
```bash
--variable keywords="keyword1, keyword2"
--variable subject="Document Subject"
```

## Complete Examples

### Professional Report
```bash
pandoc report.md -o report.pdf \
  --pdf-engine=xelatex \
  --variable geometry:margin=1in \
  --variable fontsize=12pt \
  --variable mainfont="Times New Roman" \
  --toc \
  --toc-depth=3 \
  --number-sections \
  --highlight-style=tango \
  --variable title="Annual Report 2024" \
  --variable author="Company Name" \
  --variable date="\today"
```

### Technical Documentation
```bash
pandoc documentation.md -o documentation.pdf \
  --pdf-engine=xelatex \
  --variable geometry:margin=1.5in \
  --variable fontsize=11pt \
  --variable monofont="Consolas" \
  --toc \
  --number-sections \
  --highlight-style=kate \
  --listings \
  --standalone
```

### Simple Markdown to PDF
```bash
pandoc document.md -o document.pdf \
  --variable geometry:margin=1in \
  --variable fontsize=12pt
```

### Academic Paper
```bash
pandoc paper.md -o paper.pdf \
  --pdf-engine=xelatex \
  --variable documentclass=article \
  --variable classoption=twocolumn \
  --variable geometry:margin=0.75in \
  --variable fontsize=10pt \
  --number-sections \
  --bibliography=references.bib \
  --csl=ieee.csl
```

## Troubleshooting

**Unicode characters not rendering:**
- Use `--pdf-engine=xelatex` instead of pdflatex
- Ensure proper font with Unicode support

**Images not showing:**
- Use absolute paths or paths relative to the markdown file
- Check image file permissions

**Custom fonts not working:**
- Install fonts system-wide
- Use `--variable mainfont="Font Name"`
- Requires xelatex or lualatex engine

**LaTeX errors:**
- Add `--verbose` for detailed error messages
- Check `--pdf-engine-opt` for engine-specific options

## Resources

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [Pandoc Templates](https://github.com/jgm/pandoc-templates)
- [LaTeX Font Catalogue](https://tug.org/FontCatalogue/)
