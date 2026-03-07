const {onRequest, onCall} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

// 1. SECRETS
const emailPass = defineSecret("EMAIL_PASS");
const emailUser = defineSecret("EMAIL_USER");

// 2. CONFIGURATION
const PRIORITY_KEYWORDS = ["emergency", "mandatory", "immediate", "cease", "proclamation", "violation", "penalty"];

/**
 * MAIN AGENT: sendDailyPulse
 * Automated job that scans BigQuery and emails/texts all active subscribers.
 */
exports.sendDailyPulse = onRequest({
  secrets: [emailPass, emailUser],
  region: "us-central1",
  cors: true,
  timeoutSeconds: 300,
}, async (req, res) => {
  const {BigQuery} = require("@google-cloud/bigquery");
  const nodemailer = require("nodemailer");
  const bq = new BigQuery();

  try {
    // A. Fetch Active Subscribers
    const subQuery = `SELECT email, phone_number, tier, jurisdictions, sms_enabled 
                      FROM \`regulatory-monitor-ai-agentic.regulatory_monitor.subscribers\` 
                      WHERE is_active = TRUE`;
    const [subscribers] = await bq.query(subQuery);

    // B. Fetch Latest 24-Hour Updates
    const updatesQuery = `SELECT jurisdiction, agency_name, industry_category, site_url 
                          FROM \`regulatory-monitor-ai-agentic.regulatory_monitor.enriched_scrapes\` 
                          WHERE scraped_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)`;
    const [updates] = await bq.query(updatesQuery);

    if (updates.length === 0) {
      return res.status(200).send("System Check: No new data found.");
    }

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: { user: emailUser.value(), pass: emailPass.value() },
    });

    // C. Individualized Dispatch Loop
    for (const sub of subscribers) {
      const filtered = updates.filter(u => sub.jurisdictions.includes(u.jurisdiction));
      if (filtered.length === 0) continue;

      const priority = filtered.filter(u => 
        PRIORITY_KEYWORDS.some(kw => `${u.agency_name} ${u.industry_category}`.toLowerCase().includes(kw))
      );

      const listItems = filtered.map(u => {
        const isUrgent = priority.includes(u);
        return `<li style="margin-bottom:12px; border-left:4px solid ${isUrgent ? '#d93025':'#1a73e8'}; padding-left:10px; list-style:none;">` +
               `<strong style="color:${isUrgent ? '#d93025':'#1a73e8'}">${isUrgent ? '🚨 ':''}${u.jurisdiction}</strong><br>`+
               `<b>${u.agency_name}</b> | <a href="${u.site_url}">Source</a></li>`;
      }).join("");

      await transporter.sendMail({
        from: `"Regulatory Pulse" <${emailUser.value()}>`,
        to: sub.email,
        subject: `Pulse Alert: ${filtered.length} Updates (${priority.length} Priority)`,
        html: `<div style="font-family:sans-serif; max-width:600px;"><h2>Your Daily Regulatory Briefing</h2><ul>${listItems}</ul></div>`
      });

      if (sub.sms_enabled && sub.phone_number && priority.length > 0) {
        const smsText = priority.map(p => `[${p.jurisdiction}] ${p.agency_name}`).join("\n");
        await transporter.sendMail({
          from: `"Pulse-SMS" <${emailUser.value()}>`,
          to: sub.phone_number,
          text: `🚨 URGENT REGS FOUND:\n${smsText.substring(0, 140)}`
        });
      }
    }
    res.status(200).send("Alerts dispatched successfully.");
  } catch (err) {
    console.error("Pulse Agentic Failure:", err);
    res.status(500).send("Internal Server Error.");
  }
});

/**
 * ADMIN: listSubscribers
 * Retrieves all users from the BigQuery table for the Admin Dashboard.
 */
exports.listSubscribers = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) throw new Error("Unauthorized");

  const { BigQuery } = require("@google-cloud/bigquery");
  const bq = new BigQuery();

  const query = `SELECT email, phone_number, tier, jurisdictions, sms_enabled, is_active 
                 FROM \`regulatory-monitor-ai-agentic.regulatory_monitor.subscribers\`
                 ORDER BY created_at DESC`;

  const [rows] = await bq.query(query);
  return { subscribers: rows };
});

/**
 * ADMIN: addSubscriber
 */
exports.addSubscriber = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) throw new Error("Unauthorized");

  const { email, phone, tier, jurisdictions, sms } = request.data;
  const { BigQuery } = require("@google-cloud/bigquery");
  const bq = new BigQuery();

  const query = `INSERT INTO \`regulatory-monitor-ai-agentic.regulatory_monitor.subscribers\` 
                 (email, phone_number, tier, jurisdictions, sms_enabled, is_active) 
                 VALUES (@email, @phone, @tier, @jurisdictions, @sms, TRUE)`;

  await bq.query({
    query: query,
    params: { email, phone, tier, jurisdictions: jurisdictions.split(','), sms }
  });

  return { success: true };
});

/**
 * ADMIN: updateSubscriber
 */
exports.updateSubscriber = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) throw new Error("Unauthorized");

  const { email, phone, tier, jurisdictions, sms, active } = request.data;
  const { BigQuery } = require("@google-cloud/bigquery");
  const bq = new BigQuery();

  const query = `UPDATE \`regulatory-monitor-ai-agentic.regulatory_monitor.subscribers\`
                 SET phone_number = @phone,
                     tier = @tier,
                     jurisdictions = @jurisdictions,
                     sms_enabled = @sms,
                     is_active = @active
                 WHERE email = @email`;

  await bq.query({
    query: query,
    params: { email, phone, tier, jurisdictions: jurisdictions.split(','), sms, active }
  });

  return { success: true };
});

/**
 * ADMIN: deleteSubscriber (Soft Delete)
 */
exports.deleteSubscriber = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) throw new Error("Unauthorized");

  const { email } = request.data;
  const { BigQuery } = require("@google-cloud/bigquery");
  const bq = new BigQuery();

  const query = `UPDATE \`regulatory-monitor-ai-agentic.regulatory_monitor.subscribers\`
                 SET is_active = FALSE
                 WHERE email = @email`;

  await bq.query({
    query: query,
    params: { email }
  });

  return { success: true };
});

/**
 * DEV TOOL: testSms
 */
exports.testSms = onRequest({ secrets: [emailPass, emailUser] }, async (req, res) => {
  const nodemailer = require("nodemailer");
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: { user: emailUser.value(), pass: emailPass.value() },
  });

  await transporter.sendMail({
    from: emailUser.value(),
    to: "7203619823@tmomail.net", 
    text: "Regulatory Agent: SMS Handshake Successful! ✅"
  });
  res.send("Test SMS sent.");
});