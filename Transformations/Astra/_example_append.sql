-- ============================================================================
-- Example: Astra Append Table (UNION ALL)
-- ============================================================================
-- This table unions all per-system invoice tables into a single unified view.
-- Add a new SELECT block for each source system as you onboard them.
--
-- RENAME this file to astra_{domain}_invoice.sql and update references.
-- DELETE once you have the real append table.
-- ============================================================================

create or refresh live table ${catalog_silver_astra}.my_domain.astra_invoice

comment 'Unified invoice table — all source systems combined'
tblproperties (
  'delta.columnMapping.mode' = 'name',
  'quality' = 'silver',
  'domain' = 'my_domain'
) as

-- System 1: Example
select * from ${catalog_silver_opco}.my_domain.example_invoice

-- As you add systems, append them with UNION ALL:
-- UNION ALL
-- select * from ${catalog_silver_opco}.my_domain.intacct_invoice

-- UNION ALL
-- select * from ${catalog_silver_opco}.my_domain.jonas_invoice
;
