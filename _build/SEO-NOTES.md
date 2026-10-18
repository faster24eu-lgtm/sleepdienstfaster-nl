# SEO notes – sleepdienstfaster.nl

Playbook for all Faster sites: `takeldienstfaster/SEO-STRATEGY-NO-BACKLINKS.md` (ranking without backlinks: Search Console queries → content and internal anchors).
This file lives in `_build/`, so GitHub Pages does not publish it.

## 2026-10-18 – contextual internal links (no text changes)
Search Console (`https://sleepdienstfaster.nl/`, data 2026-10-10 to 2026-10-16): 26 pages with impressions, 668 impressions, 1 click. Most pages sit at positions 40–90; too early for title/content changes from queries. Re-check from ~2026-11-08.
Closest to page 1: /kennisbank/pech-op-de-snelweg/ (32 impr., pos 26; "pech op de snelweg" 25, "pech op snelweg" 11), /diensten/elektrische-auto-slepen/ (17 / 28; "elektrische auto slepen" 16), /sleepdienst/tilburg/ (20 / 41; "sleepservice" 7), /sleepdienst/den-bosch/ ("sleepdienst den bosch" 19), /sleepdienst/bergen-op-zoom/ (pos 10).
Many impressions are "vrachtwagen sleepdienst in <plaats>" at positions 50–100 (trucks; since 2026-10-19 targeted by /diensten/vrachtwagen-slepen/, see below).

Change in `build.pl`: `link_mentions()` runs on every page. The first unlinked mention of a city name or a guide topic (`%GUIDE_PHRASES`) in a `<p>`/`<li>` becomes a link; max 3 per page, least-linked targets first. Never inside card links, reviews (`<figure>`, `<blockquote>`) or paragraphs that quote a customer; the "Ook in de buurt" block does not count as already linked. The build dies if the visible text changes.
Result: 73 new contextual links. City pages had 2 in-body links each (hub list + one other); now mostly 3–6. Sleepdienst zonder abonnement 3 → 15.

## 2026-10-19 – new page /diensten/vrachtwagen-slepen/
Search Console 2026-10-01 to 18: 301 impressions for truck searches ("vrachtwagen sleepdienst in <plaats>", "vrachtwagen pechhulp in maasvlakte/pernis"), mostly on /sleepdienst/ and /sleepdienst/rotterdam/ at positions 40–90; the best were Botlek (39) and Maasvlakte (44). There was no truck page.
The page is honest about capacity: own trucks load up to 3.500 kg (as on the bestelbus page); heavier jobs with fixed partners with heavy recovery vehicles, one number, price beforehand. Sections: what we arrange, Rotterdam port (A15, Maasvlakte, Europoort, Botlek, Pernis, terminal access), process, motorway (112 / Rijkswaterstaat 0800-8002, designated berger for incidents), exceptional transport (2,55 m / 4 m, RDW ontheffing), price factors, transport companies. kind: dienst, so every city page links it via "Wat wij doen in …".
Owner confirmed 2026-10-19: Faster has partners for trucks in the Netherlands. Still to confirm: whether fixed agreements for transport companies are offered here too.
