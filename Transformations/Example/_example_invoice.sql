-- ============================================================================
-- Example: Source System Invoice Table
-- ============================================================================
-- This is a template showing the standard DLT invoice table structure.
-- Copy this file, rename it to {system}_{domain}_invoice.sql, and update
-- the bronze table references and column mappings for your source system.
--
-- DELETE this file once you have real transformations.
-- ============================================================================

create or refresh live table ${catalog_silver_opco}.my_domain.example_invoice

(
  -- Data quality constraints — add checks relevant to your domain
  CONSTRAINT pk_not_null EXPECT (`Invoice Id` IS NOT NULL),
  CONSTRAINT amount_not_null EXPECT (`Invoice Amount` IS NOT NULL),
  CONSTRAINT date_not_null EXPECT (`Invoice Date` IS NOT NULL)
)
comment 'Example invoice table — replace with your domain description'
tblproperties (
  'delta.columnMapping.mode' = 'name',
  'quality' = 'silver',
  'domain' = 'my_domain',
  'source_system' = 'example',
  'companies' = 'Example Company A, Example Company B'
) as

-- Step 1: Pull raw data from bronze
with source_data as (
    select *
    from bronze_opco.example_system.example_invoices
),

-- Step 2: Apply any business logic, filtering, deduplication
cleaned as (
    select *
    from source_data
    where is_deleted = false  -- Example: filter deleted records
),

-- Step 3: Map to standardized schema — column ORDER matters for UNION ALL
final as (
    select
        CAST(invoice_key AS STRING)                     as `Invoice Id`,
        CAST(invoice_number AS STRING)                  as `Invoice Number`,
        CAST(customer_key AS STRING)                    as `Customer Id`,
        'Example Company A'                             as `Company Name`,
        COALESCE(work_type, 'Other')                    as `Work Scope`,
        CAST(invoice_date AS DATE)                      as `Invoice Date`,
        CAST(due_date AS DATE)                          as `Due Date`,
        CAST(payment_terms_days AS INT)                 as `Payment Terms`,
        CAST(total_amount AS DECIMAL(18,2))             as `Invoice Amount`,
        CAST(balance_due AS DECIMAL(18,2))              as `Total Due Validation`,
        'Example'                                       as `System`
    from cleaned
)

select * from final
;
