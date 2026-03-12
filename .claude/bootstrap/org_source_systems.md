---
name: Astra source systems overview
description: ERP and accounting systems that feed into Astra DLT pipelines, with bronze catalog patterns
type: reference
---

## Source Systems

| System | Type | Domains | Bronze Pattern | Notes |
|--------|------|---------|----------------|-------|
| Intacct | Accounting | AR, AP | `bronze_opco.intacct.*` | Multi-entity, most companies |
| Jonas | ERP | AR, AP | `bronze_opco.jonas.*` | GE Mechanical, Lowe, TCS |
| Vista | ERP | AP | `bronze_opco.vista.*` | Apcco Operations |
| DynamicsGP | ERP | AR, AP | `bronze_opco.dynamicsgp.*` | Griffen |
| COINS | ERP | AR, AP | `bronze_opco.coins.*` | TCS, ASI, Tustin entities |
| SAMPro | ERP | AR, AP | `bronze_opco.sampro.*` | Helios HVACR |
| Spectrum | ERP | AR | `bronze_opco.spectrum.*` | Modern Controls |
| Sage300 | ERP | AP | `bronze_opco.sage300.*` | Champion Industrial |
| Davisware | ERP | AR | `bronze_opco.davisware.*` | BERCO |
| QuickBooks Desktop | Accounting | AR, AP | `bronze_opco.quickbooks_desktop.*` | Josko, Agentis, Simcoe, Dael, LAH, ASI |
| QuickBooks Online | Accounting | AR, AP | `bronze_opco.quickbooks_online.*` | |
| ServiceTitan | Field Service | Operations | `bronze_opco.servicetitan.*` | AP managed in QuickBooks |
| ASystems | ERP | AP | `bronze_opco.asystems.*` | Streets only |

## Common Company Abbreviations

| Abbreviation | Full Name | System |
|-------------|-----------|--------|
| TCS | Texas Chiller Systems | COINS |
| ASI | Aireko Services & Installation | COINS |
| GEM / GE | GE Mechanical | Jonas |
| Lowe | Lowe Mechanical Services Ltd | Jonas |
| Griffen | Griffen Plumbing and Heating | Dynamics GP |
| Champion | Champion Industrial Contractors | Sage300 |
| Apcco | Apcco Operations | Vista |
| Helios | Helios HVACR | SAMPro |
| Modern | Modern Controls | Spectrum |
| BERCO | BERCO | Davisware |
| LAH | LA Hydro Jet | QuickBooks Desktop |
