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
