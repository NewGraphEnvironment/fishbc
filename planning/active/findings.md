# Findings: CDC Data Update Investigation

## Current State (2026-02-06)

### Upstream (poissonconsulting/fishbc)
- `cdc.csv` last updated: 2020-05-28
- Issue #13 still OPEN
- Lucy's PR #14 is DRAFT/stale since Aug 2024
- Maintainer (Joe) gave clear guidance on approach

### Data Structure

**Current cdc.csv columns:**
- Species Code, Element Code, Scientific Name, English Name
- BC List, Provincial FRPA, COSEWIC, SARA
- (and more - need full column inventory)

**CDC Export Changes:**
- Format changed since 2020
- Summary Data export now preferred
- Some columns renamed (Municipality → Municipalities, etc.)

### Species Changes Identified (from Lucy's analysis)

**Removed from CDC:**
- Oncorhynchus nerka pop. 30, pop. 31

**Name/Code Changes:**
- Catostomus platyrhynchus → Catostomus bondi (F-CAPL → F-CABO)
- Sebastes mystinus → Sebastes diaconus
- Lampetra richardsoni - Element Code changed
- Catostomus macrocheilus - Element Code changed

**New Species:**
- Mola tecta
- Oncorhynchus mykiss - coastal lineage
- Oncorhynchus mykiss - interior lineage
- Thaleichthys pacificus pop. 1, 2, 3

### The Bull Trout Complexity

Arctic Bull Trout (Salvelinus confluentus) populations have different listings:
- Western Arctic populations: Special Concern
- Pacific populations: Not listed

This requires careful handling in the SAR table to avoid misrepresenting status.

## Open Questions

1. Current CDC Summary Data export - need to download fresh copy
2. Full column inventory comparison needed
3. How to handle population-level distinctions in existing data model?

## Column Mapping Analysis (2026-02-06)

### Columns in OLD but renamed in NEW:
- `Ecosection` → `Ecosections`
- `MOE Region` → `ENV Regional Boundaries`
- `Regional Dist` → `Regional Districts`
- `Municipality` → `Municipalities`
- `Name Category` → `Classification Level`
- `CDC Maps` → `Mapping Comment`
- `MBCA` → `Migratory Bird Convention Act`
- `Habitat Subtype` → `Habitats (Type / Subtype / Dependence)`

### Columns in OLD but MISSING in NEW:
- `Species Level` (need to verify)

### Columns in NEW but NOT in OLD:
- `Scientific Name - Concept Reference`
- `Taxonomy Comments`
- `Provincial FRPA Comments`
- `COSEWIC Date`
- `SARA Schedule`
- `SARA Status`
- `SARA Date`
- `Natural Resource (NR) Districts`
- `Natural Resource (NR) Regions`
- `Ecoregions`
- `BC Parks, Ecological Reserves, and PAs`
- `National Parks`
- `Local Trust Areas`

### Key Structural Changes:
1. OLD had composite `SARA` column (e.g., "1-SC (Aug 2006)")
2. NEW has separate `SARA Schedule`, `SARA Status`, `SARA Date` columns
3. Same pattern for COSEWIC - NEW has separate `COSEWIC Date`
4. Column ORDER is different - need to reorder to match old

### Strategy:
1. Rename new column names to match old
2. Combine SARA Schedule + Status + Date into composite `SARA` column
3. Combine COSEWIC + Date into composite `COSEWIC` column
4. Reorder columns to match old cdc.csv
5. Drop extra columns not in old (or add at end per Joe's guidance)
