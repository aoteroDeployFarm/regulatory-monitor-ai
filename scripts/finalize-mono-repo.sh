#!/bin/bash

echo "🚀 Finalizing Monorepo Structure for Fabing Productions..."

# 1. Rename regulatory config for consistency
if [ -f "packages/configs/sites.json" ]; then
    echo "📝 Renaming sites.json to regulatory_sites.json..."
    mv packages/configs/sites.json packages/configs/regulatory_sites.json
fi

# 2. Move SQL logic into packages for Docker inclusion
if [ -d "sql" ]; then
    echo "📂 Moving SQL directory to packages/configs/sql/..."
    mkdir -p packages/configs/sql
    mv sql/* packages/configs/sql/
    rmdir sql
fi

# 3. Clean up redundant root-level source files
if [ -d "src" ]; then
    echo "🧹 Removing redundant root-level src/ directory..."
    rm -rf src
fi

# 4. Final Verification of Paths
echo "--------------------------------------------------------"
echo "✅ Migration Steps Complete."
echo "📍 Regulatory Config: packages/configs/regulatory_sites.json"
echo "📍 Property Config:   packages/configs/property_sites.json"
echo "📍 SQL Logic:         packages/configs/sql/"
echo "--------------------------------------------------------"