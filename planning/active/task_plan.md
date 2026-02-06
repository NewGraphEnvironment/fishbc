# Task: Update CDC Species at Risk Data

**Issue Reference:** poissonconsulting/fishbc#13
**Branch:** issue-13-cdc-sar-update
**Started:** 2026-02-06

## Objective

Update `data-raw/cdc/cdc.csv` with current BC Conservation Data Centre data following maintainer guidelines.

## Milestones

### Phase 1: Analysis
- [ ] Review current cdc.csv structure and columns
- [ ] Review Lucy's approach in lucy-schick/fishbc@updated_data
- [ ] Identify column mapping between old and new CDC exports
- [ ] Document species code changes (name/code migrations)

### Phase 2: Implementation
- [ ] Download fresh CDC Summary Data export
- [ ] Create `data-raw/cdc/cdc.R` wrangling script (per Joe's guidance)
- [ ] Save raw download as `data-raw/cdc/raw.csv`
- [ ] Wrangle to match existing column format
- [ ] Update freshwaterfish.csv CDCode references as needed

### Phase 3: Validation
- [ ] Run data-raw.R checks
- [ ] Verify chk::chk_join passes
- [ ] Test package build
- [ ] Document edge cases (subspecies, populations)

### Phase 4: PR Workflow
- [ ] PR to NewGraphEnvironment/fishbc (this branch → master)
- [ ] After merge, PR from NGE to poissonconsulting/fishbc

## Key Constraints

1. Column names/order must match existing cdc.csv for compatibility
2. New columns can be added at end only
3. Scripts go in data-raw/, not R/
4. Must handle Arctic vs Pacific Bull Trout population distinctions

## References

- Joe's guidance: poissonconsulting/fishbc#13 comments
- Lucy's work: R/cdc.Rmd in lucy-schick/fishbc@updated_data
- CDC source: https://a100.gov.bc.ca/pub/eswp/
