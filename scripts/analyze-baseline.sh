#!/bin/bash

PROJECT_ID="regulatory-monitor-ai-agentic"

# This uses the exported SOURCE_ID from the parent script, or defaults to alabama-0
CURRENT_ID="${SOURCE_ID:-alabama-0}"

echo "--------------------------------------------------------"
echo "🧠 AI ANALYSIS: $CURRENT_ID"
echo "--------------------------------------------------------"

bq query --project_id=$PROJECT_ID --use_legacy_sql=false <<EOF
  SELECT
    ml_generate_text_llm_result AS summary
  FROM
    ML.GENERATE_TEXT(
      MODEL \`regulatory_monitor.gemini_2_pro\`,
      (
        SELECT
          CONCAT('Analyze this regulatory page and list any active permits, upcoming hearings, or recent rule changes in bullet points: ', content) AS prompt
        FROM
          \`$PROJECT_ID.regulatory_monitor.raw_scrapes\`
        WHERE
          source_id = '$CURRENT_ID'
        ORDER BY
          scraped_at DESC
        LIMIT 1
      ),
      STRUCT(
        0.2 AS temperature, 
        1000 AS max_output_tokens,
        TRUE AS flatten_json_output
      )
    );
EOF

echo "--------------------------------------------------------"
echo "✅ Analysis Complete."