import puppeteer from "puppeteer";
import handlebars from "handlebars";

const fs = require("fs");
const path = require("path");

export async function generateRentalAgreement(req, res) {
  try {
    const data = req.body;
    const hbsFile = fs.readFileSync(
      path.resolve("templates", "rentalAgreement.hbs"),
      "utf8"
    );
    const browser = await puppeteer.launch({
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
    const page = await browser.newPage();
    const template = handlebars.compile(hbsFile, { strict: true });
    const html = template(data);
    await page.setContent(html, {
      waitUntil: "networkidle0", // wait for page to load completely
    });
    const pdfGenerated = await page.pdf({
      format: "A4",
      printBackground: true,
      margin: { top: "1cm", right: "1cm", bottom: "1cm", left: "1cm" },
    });
    res.set({
      "Content-Type": "application/pdf",
      "Content-Length": pdfGenerated.length,
    });
    res.send(pdfGenerated);
    await browser.close();
  } catch (err) {
    return res
      .status(500)
      .json({ error: `error while generating a renatl agreement file ${err}` });
  }
}
