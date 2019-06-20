'use strict';

const puppeteer = require('puppeteer');

const createPdf = async () => {
    let browser;
    try {
        browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });
        const page = await browser.newPage();
        const htmlPath = process.argv[2];

        console.log(htmlPath);

        await page.goto(`file:${htmlPath}`, {
            waitUntil: 'networkidle0'
        });
        await page.pdf({
            path: process.argv[3],
            format: 'A4',
            margin: {top: 0, right: 0, bottom: 0, left: 0},
            printBackground: true
        });
    } catch (err) {
        console.error(err);
        console.error(err.message);
    } finally {
        console.log('teardown');

        if (browser) {
            browser.close();
        }
        process.exit();
    }
};
createPdf();
