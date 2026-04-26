# Portfolio Maturity Roadmap

**Last updated:** April 2026  
**Scope:** MS Security Compass portfolio — `landing_page_v1.html` (index), `ms_security_compass_v20.html`, `ms_security_projects_v1.html`, `ms_security_roles_v2.html`, `certification_strategy_v1.html`, `skills_inventory_draft_v1.html`

---

## P0 — Fix before sharing externally

### ✅ 0. Landing page built
**File:** `landing_page_v1.html` → publishes as `index.html`  
**Status: Complete.** Landing page with hero, portfolio card grid, and footer is built and ready to publish. Links to all four main portfolio pages. Update the "Last updated" footer timestamp on every push (reminder comment embedded in file).

### ✅ 1. Fix the broken cross-page link
**File:** `ms_security_roles_v2.html` nav + footer  
**Status: Complete.** Both the nav and footer Compass links updated from `ms_security_compass_v19.html` to `ms_security_compass_v20.html`. The Certifications link (`certification_strategy_v1.html`) was already correct.

### 🔄 2. Wire the `sendPrompt()` fallback
**File:** `ms_security_compass_v20.html`  
**Status: In progress** — fallback added in Compass context window; pending verification on GitHub Pages.  
**Issue:** "Real-world scenario ↗" buttons are dead outside Claude.ai — no function, no feedback, nothing happens.  
**Fix:** Add the fallback snippet documented in `GITHUB_PAGES_PUBLISHING.md` just before `</script>`:
```js
if (typeof sendPrompt === 'undefined') {
  window.sendPrompt = function(text) {
    window.open('https://claude.ai/new?q=' + encodeURIComponent(text), '_blank');
  };
}
```
**Why it's P0:** The Compass's most distinctive interactive feature is silently broken for every external viewer.

---

## P1 — High impact, do soon

### ✅ 3. Fill the placeholder cards in Projects
**File:** `ms_security_projects_v1.html`  
**Status: Complete.** Pending/placeholder projects moved to `ms_security_projects_roadmap_v1.html` — the current projects page now reflects only real, completed work.

### ✅ 4. Add a landing / "about" context block to the Compass
**File:** `ms_security_compass_v20.html`  
**Status: Complete.** A context block with professional framing and a "← Back to portfolio" nav link were added to `ms_security_compass_v20.html`. External viewers now have immediate context for who built this and why before engaging with the SVG.

### ✅ 5. Calibrate Skills Inventory ratings before publishing
**File:** `skills_inventory_v1.html` (formerly `skills_inventory_draft_v1.html`)  
**Status: Complete.** Ratings calibrated against the `SKILLS_CALIBRATION_GUIDE.md` binding scale. Draft banners and "Draft v1" labels removed. File is publish-ready. Update the "Last updated" footer timestamp on every push (reminder comment embedded in file).

---

## P2 — Meaningful improvement, lower urgency

### 6. Add one concrete scenario per role
**File:** `ms_security_roles_v2.html`  
**Issue:** Role descriptions are well-written but read as job descriptions — claims without evidence.  
**Fix:** Add one short scenario paragraph per role card (3–5 sentences) in the format: "A client came to us with X — here is what we did and what shipped." Real client names not needed; the scenario structure is what counts.  
**Why it's P2:** Transforms the Roles page from a self-assessment into a track record. High value for external conversations; lower urgency because the current page still holds up on its own.

### 7. Add a visual roadmap timeline to the Certifications page
**File:** `certification_strategy_v1.html`  
**Issue:** The page reads as static. The planned path (SC-300 → SC-401 → SC-500 → SC-100) exists in prose but has no visual sense of sequence or timing.  
**Fix:** Add a simple milestone chip row or table showing target quarter per exam. Anchor the first milestone to the AZ-500 retirement date (Aug 31, 2026) to make the urgency concrete.  
**Why it's P2:** Makes the roadmap feel active and intentional rather than aspirational. Particularly useful when the page is shared directly with a hiring manager or partner.

### 8. Improve GitHub project granularity
**File:** `ms_security_projects_v1.html` + GitHub repo  
**Issue:** Most project cards link to a single top-level folder (`marcusjacobson/Projects/tree/main/Microsoft`) rather than individual repos or topic-filtered views. As the portfolio grows this becomes an undifferentiated blob.  
**Fix:**
- Add GitHub topic tags to individual repos (`microsoft-sentinel`, `purview`, `entra-id`, `defender-xdr`, etc.)
- Update project card links to point to repo- or topic-specific URLs rather than the parent folder
- See `GITHUB_LINKING.md` for URL pattern reference

**Why it's P2:** Pays compounding dividends — every new project added becomes individually discoverable and linkable from the compass nodes.

---

## P3 — Polish, do when time allows

### 9. Mobile responsiveness for the Compass
**File:** `ms_security_compass_v20.html`  
**Issue:** The SVG uses a fixed `viewBox` and does not reflow on narrow screens. Usable on desktop; degraded on phones.  
**Note:** Low priority for a B2B / consulting portfolio — most reviewers will be on desktop. Worth addressing before any LinkedIn post that might drive mobile traffic.

### 10. Remove version numbers from published filenames
**File:** GitHub Pages repo  
**Issue:** Version-numbered filenames (`_v20`, `_v2`, `_v1`) are visible in the browser URL bar and look like works-in-progress.  
**Fix:** The `GITHUB_PAGES_PUBLISHING.md` rename step already handles this for the Compass (`index.html`). Apply the same clean naming to the other files on next push.  
**Note:** Only affects perception, not function. Do this on the next natural update cycle.

---

## Ongoing habits

- **Keep section counts accurate** in `ms_security_projects_v1.html` — stale counts (e.g., "1 project" with three real cards) undermine the impression of a maintained portfolio.
- **Bump the version and date** in page footers when making meaningful content changes.
- **Test all cross-page nav links** after any file rename or push — the pages reference each other in headers and footers.
- **Add GitHub links to Compass nodes** as new lab projects are completed — the `github:[]` array in each `D` entry is ready to receive them.
- **Project knowledge files are read-only in Claude** — Compass edits must be made in a dedicated Compass context window, then pushed to GitHub. Do not attempt to edit source files from the portfolio project context.
- **Update "Last updated" in `landing_page_v1.html` and `skills_inventory_draft_v1.html` footers on every push** — reminder comments are embedded in both files.
