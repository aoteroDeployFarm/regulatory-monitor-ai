import { onRequest, Request } from "firebase-functions/v2/https";
import { Response } from "express"; 
import { BigQuery } from '@google-cloud/bigquery';
import * as nodemailer from 'nodemailer';
import { defineSecret } from "firebase-functions/params";

// 1. Secure Secret Definitions
// Ensure these are set via: firebase functions:secrets:set EMAIL_USER (and EMAIL_PASS)
const emailPass = defineSecret("EMAIL_PASS");
const emailUser = defineSecret("EMAIL_USER");

const bq = new BigQuery();

/**
 * The Regulatory Pulse Agent
 * Logic: Queries BigQuery for 24h updates and sends an HTML briefing via Gmail.
 */
export const sendDailyPulse = onRequest({ 
  secrets: [emailPass, emailUser],
  region: "us-central1",
  cors: true // Allows you to trigger this from a web dashboard later if needed
}, async (req: Request, res: Response) => {
  
  // 2. The Pulse Query
  // Monitoring Hawaii, Georgia, Florida, and California
  const query = `
    SELECT jurisdiction, agency_name, industry_category, site_url 
    FROM \`regulatory-monitor-ai-agentic.regulatory_monitor.enriched_scrapes\` 
    WHERE scraped_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    ORDER BY jurisdiction ASC
  `;

  try {
    const [rows] = await bq.query(query);

    if (rows.length === 0) {
      console.log("Pulse Check: No new regulatory updates found.");
      res.status(200).send("System Check: 0 new updates found in the last 24h.");
      return;
    }

    // 3. Configure the Mail Agent
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: { 
        user: emailUser.value(), 
        pass: emailPass.value() 
      }
    });

    // 4. Build the HTML Briefing
    const listItems = rows.map((r: any) => `
      <li style="margin-bottom: 15px; border-left: 4px solid #1a73e8; padding-left: 12px; list-style: none;">
        <strong style="font-size: 16px; color: #1a73e8;">${r.jurisdiction}</strong><br>
        <span style="font-weight: bold;">${r.agency_name}</span><br>
        <small style="color: #666;">Category: ${r.industry_category}</small><br>
        <a href="${r.site_url}" target="_blank" style="color: #1a73e8; text-decoration: underline; font-size: 13px;">View Source Document</a>
      </li>
    `).join('');

    // 5. Dispatch the Alert
    await transporter.sendMail({
      from: `"Regulatory Monitor Agent" <${emailUser.value()}>`,
      to: "aoterodevworks@gmail.com",
      subject: `🚨 Pulse Alert: ${rows.length} New State Regulatory Updates`,
      html: `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px;">
          <h2 style="color: #1a73e8; border-bottom: 2px solid #1a73e8; padding-bottom: 10px;">National Regulatory Pulse</h2>
          <p style="font-size: 16px;">The monitoring agent detected <strong>${rows.length} updates</strong> in the last 24 hours.</p>
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 8px;">
            ${listItems}
          </div>
          <p style="font-size: 12px; color: #999; margin-top: 30px; text-align: center;">
            Sent by <strong>Fabing Productions Agentic AI</strong> <br>
            Project: regulatory-monitor-ai-agentic
          </p>
        </div>
      `
    });

    res.status(200).send(`Success: ${rows.length} alerts dispatched to your inbox.`);
    
  } catch (error) {
    console.error("Agentic Failure:", error);
    res.status(500).send("The agent encountered an error processing BigQuery data. Check Firebase Logs.");
  }
});