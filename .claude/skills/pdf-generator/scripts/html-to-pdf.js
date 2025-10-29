#!/usr/bin/env node
/**
 * HTML to PDF Converter using Playwright
 *
 * Converts HTML files (including dynamic presentations) to PDF format.
 * Handles JavaScript-based presentations like reveal.js.
 *
 * Usage:
 *   node html-to-pdf.js <input.html> <output.pdf> [options]
 *
 * Options:
 *   --landscape    Use landscape orientation (default for presentations)
 *   --portrait     Use portrait orientation
 *   --wait <ms>    Wait time in milliseconds before generating PDF (default: 2000)
 *
 * Examples:
 *   node html-to-pdf.js presentation.html slides.pdf
 *   node html-to-pdf.js document.html document.pdf --portrait
 *   node html-to-pdf.js complex.html output.pdf --wait 5000
 *
 * Prerequisites:
 *   npm install playwright
 *   npx playwright install chromium
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function convertHTMLtoPDF(inputPath, outputPath, options = {}) {
    const {
        landscape = true,
        waitTime = 2000,
        format = 'A4'
    } = options;

    console.log(`Converting: ${inputPath} -> ${outputPath}`);
    console.log(`Options: landscape=${landscape}, waitTime=${waitTime}ms`);

    // Validate input file exists
    if (!fs.existsSync(inputPath)) {
        throw new Error(`Input file not found: ${inputPath}`);
    }

    // Get absolute path for the HTML file
    const absolutePath = path.resolve(inputPath);
    const fileUrl = `file:///${absolutePath.replace(/\\/g, '/')}`;

    console.log(`Loading: ${fileUrl}`);

    // Launch browser
    const browser = await chromium.launch({
        headless: true
    });

    try {
        const context = await browser.newContext({
            viewport: landscape ? { width: 1920, height: 1080 } : { width: 1080, height: 1920 }
        });

        const page = await context.newPage();

        // Navigate to the HTML file
        await page.goto(fileUrl, {
            waitUntil: 'networkidle',
            timeout: 30000
        });

        // Wait for any dynamic content to load
        await page.waitForTimeout(waitTime);

        // Generate PDF
        await page.pdf({
            path: outputPath,
            format: format,
            landscape: landscape,
            printBackground: true,
            margin: {
                top: '20px',
                right: '20px',
                bottom: '20px',
                left: '20px'
            },
            preferCSSPageSize: false
        });

        console.log(`✓ PDF generated successfully: ${outputPath}`);

    } catch (error) {
        console.error(`✗ Error generating PDF:`, error.message);
        throw error;
    } finally {
        await browser.close();
    }
}

// Command-line interface
if (require.main === module) {
    const args = process.argv.slice(2);

    if (args.length < 2) {
        console.error('Usage: node html-to-pdf.js <input.html> <output.pdf> [options]');
        console.error('');
        console.error('Options:');
        console.error('  --landscape    Use landscape orientation (default)');
        console.error('  --portrait     Use portrait orientation');
        console.error('  --wait <ms>    Wait time before PDF generation (default: 2000ms)');
        console.error('');
        console.error('Examples:');
        console.error('  node html-to-pdf.js presentation.html slides.pdf');
        console.error('  node html-to-pdf.js document.html document.pdf --portrait');
        console.error('  node html-to-pdf.js complex.html output.pdf --wait 5000');
        process.exit(1);
    }

    const inputPath = args[0];
    const outputPath = args[1];

    const options = {
        landscape: !args.includes('--portrait'),
        waitTime: 2000
    };

    // Parse wait time option
    const waitIndex = args.indexOf('--wait');
    if (waitIndex !== -1 && args[waitIndex + 1]) {
        options.waitTime = parseInt(args[waitIndex + 1], 10);
    }

    convertHTMLtoPDF(inputPath, outputPath, options)
        .then(() => {
            console.log('Done!');
            process.exit(0);
        })
        .catch(error => {
            console.error('Failed:', error.message);
            process.exit(1);
        });
}

module.exports = { convertHTMLtoPDF };
