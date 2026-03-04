Regulatory Monitor AI Agent

Automated Regulatory Tracking and AI Analysis (2026 Build)

An end-to-end agentic workflow that monitors 560+ state regulatory websites, detects content changes, and uses Gemini 2.5 Pro to extract:

Active permits

Upcoming hearings

Proposed rule changes

Regulatory updates

This system is built for continuous monitoring, cost efficiency, and production reliability.

System Overview

This system operates as a continuous intelligence loop:

Scrape regulatory websites

Hash content to detect changes

Store raw text in BigQuery

Trigger AI analysis only when necessary

Generate structured regulatory summaries

Design Principle: AI is invoked only when content changes.
This eliminates redundant LLM calls and keeps costs predictable.

🏗️ Architecture
The Hand — Scraper Layer

Stack: Node.js + Playwright

Navigates complex, JavaScript-heavy state websites

Extracts normalized raw text

Handles dynamic rendering and non-standard DOM structures

Designed for bulk execution across 560+ sources

Runs locally (or containerized) and pushes results upstream.

The Memory — Data Layer

Platform: BigQuery
Dataset: regulatory_monitor
Primary Table: raw_scrapes

Each record includes:

source_id

scraped_at

content

content_hash

The content_hash prevents redundant AI processing.
If the hash has not changed, analysis is skipped.

The Brain — AI Layer

Model: Gemini 2.5 Pro
Integration: Vertex AI via BigQuery CLOUD_RESOURCE connection
Connection: us-central1.gemini_connection
Model Name: regulatory_monitor.gemini_2_pro

Gemini is invoked directly from BigQuery using:

ML.GENERATE_TEXT()

This keeps inference inside the data warehouse boundary and avoids additional orchestration infrastructure.

🚀 Getting Started
1. Google Cloud Project Setup

Ensure the following resources exist:

Component	Required Value
Project	regulatory-monitor-ai-agentic
Dataset	regulatory_monitor
Connection	us-central1.gemini_connection
Model	gemini_2_pro → gemini-2.5-pro endpoint
2. Local Scraper Setup

From the project root:

npm install
npm run start

Ensure the scraper service is running before triggering bulk runs.

🛠️ Automation Scripts

All scripts are located in the scripts/ directory.

Script	Purpose
bulk-scrape.sh	Iterates through sites.json, triggers scraping, and initiates change detection
check-for-changes.sh	Compares latest content_hash in BigQuery; triggers AI only if changed or FIRST_RUN
analyze-baseline.sh	Sends raw text to Gemini and extracts structured regulatory bullet points
🏃 Running the Monitor
Run a Single State (Recommended for Testing)
./scripts/bulk-scrape.sh alabama
Run All 560+ Sites
./scripts/bulk-scrape.sh
📊 Viewing Results

Run the following saved query in BigQuery.

Saved Query Name: Get_Alabama_Regulatory_Summaries

SELECT 
  source_id, 
  scraped_at, 
  ml_generate_text_llm_result AS ai_summary
FROM 
  ML.GENERATE_TEXT(
    MODEL `regulatory_monitor.gemini_2_pro`,
    (
      SELECT 
        source_id, 
        scraped_at, 
        content AS prompt
      FROM `regulatory_monitor.raw_scrapes`
    ),
    STRUCT(TRUE AS flatten_json_output)
  )
ORDER BY scraped_at DESC;
Important Implementation Detail

The alias:

content AS prompt

is required for proper BigQuery rendering of ML.GENERATE_TEXT output.

Without this alias, results will not materialize correctly.

🔒 Security & Governance
Project Tagging

The project is bound to:

863190507326/environment/Development

This ensures compliance with organization-level policy enforcement.

💰 Cost Optimization Strategy

AI analysis is triggered only when a content_hash mismatch is detected.

This design:

Prevents duplicate LLM calls

Keeps inference spend predictable

Enables safe national-scale execution

📈 Operational Flow

Scrape

Hash

Compare

Analyze (conditional)

Supports:

Horizontal scaling

Batch or scheduled execution

Future migration to streaming pipelines

🧱 Production Considerations

Before scaling to full national runs:

Add retry logic to scraper failures

Implement structured logging

Add monitoring alerts for scrape errors

Track LLM token usage

Partition BigQuery tables by scraped_at

Consider regional sharding as data volume grows

📌 Roadmap Ideas

Structured JSON extraction instead of bullet summaries

Delta comparison between content versions

Email or Slack regulatory alerts

Scheduled Cloud Run execution

Permit classification by industry

License

Internal / Proprietary (Adjust as needed)


# 🏛️ National Regulatory Intelligence Engine
**Founder:** Alex Otero | Fabing Productions

## 🚀 Overview
A high-frequency monitoring system that tracks 560+ state-level regulatory agencies across all 50 U.S. states. This system identifies real-time changes in environmental, energy, and property management compliance.

## 🛠️ The Tech Stack
* **Ingestor:** Node.js Scraper (Puppeteer/Cheerio)
* **Warehouse:** Google BigQuery
* **Classifier:** SQL-based Regex Industry Tagging
* **Analysis:** Content-Hash Change Detection

## 📁 SQL Directory Guide
1. **setup-create-sites-master.sql**: The 50-state agency directory.
2. **create-view-enriched-scrapes.sql**: The "Translation Layer" joining raw data to human names.
3. **op-bulk-categorize-master.sql**: Automatic industry tagging for 560+ sites.
4. **audit-daily-changes.sql**: The "Delta Engine" that finds the "CONTENT UPDATED" alerts.
5. **search-national-keywords.sql**: National keyword search with context snippets.