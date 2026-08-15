-- ============================================================================
-- 08_AGENT.SQL — Cortex Agent for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA APP;

CREATE OR REPLACE CORTEX AGENT APP.SUPPLY_CHAIN_INTELLIGENCE_AGENT
  COMMENT = 'Semiconductor Supply Chain Visibility AI Assistant'
  MODEL = 'claude-opus-4-8'
  TOOLS = (
    SEMANTIC_VIEW_TOOL(SEMANTIC_VIEW => 'SEMICONDUCTOR_SUPPLY_CHAIN.APP.SUPPLY_CHAIN_ANALYTICS'),    CORTEX_SEARCH_TOOL(CORTEX_SEARCH_SERVICE => 'SEMICONDUCTOR_SUPPLY_CHAIN.SEARCH.SUPPLIER_DOCS_SEARCH', TOOL_DESCRIPTION => 'Search documents for Semiconductor & Electronics Manufacturing information')
  )
  SYSTEM_PROMPT = 'You are the Supply Chain Intelligence Agent for a semiconductor company managing 50 suppliers across the Penang/Kulim corridor in Malaysia.';
