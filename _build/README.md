# Building sleepdienstfaster.nl

Every page is generated. **Edit the sources in `_build/pages/`, never the `.html` files.**

```
perl _build/build.pl
```

writes every page, `sitemap.xml` and `robots.txt`, and reports broken internal links (should be 0).

- `_build/pages/sleepdienst/breda.page` → `sleepdienst/breda/index.html`
- Phone, WhatsApp, e-mail, price, address and the menu are set at the top of `build.pl`.
- New city: copy an existing city page (e.g. `sleepdienst/breda.page`), change every field and write new ROADS / LOCAL / ROUTE text with real local facts. Do not copy text from another city: near-identical city pages are a risk with Google.
- `kind: dienst` and `kind: gids` pages show up automatically on the Diensten and Kennisbank pages; `kind: city` pages on the Werkgebied page, grouped by `province`.

GitHub Pages ignores folders starting with `_`, so `_build/` is not published.

## Before launch

1. `$PREVIEW = 1` in `build.pl` puts noindex on every page and blocks crawling in robots.txt. Set it to 0 and rebuild only when the site runs on sleepdienstfaster.nl.
2. Add a `CNAME` file containing `sleepdienstfaster.nl` once the domain's DNS points to GitHub Pages (not before, or the github.io preview link stops working).
3. Phone and WhatsApp are the Dutch number +31 97 010229095 (since 2026-10-17; replaced the Belgian +32 3 375 67 37). Owner decision 2026-10-10: Belgium is not mentioned anywhere on this site (no address, no .be links, no cross-border service).
4. Price "vanaf €125" is the Belgian price; check it is right for the Netherlands.
5. No company address or company number on the site yet (owner removed the Antwerp address). Dutch consumers and the law expect company details; decide what to show.
6. No tracking tags yet. Adding Google Ads / Analytics tags needs a cookie banner first.

## Duplicate-content check

Run `perl _build/check_similarity.pl` after adding or changing city pages. On 2026-10-10 every city page shared at most 26-37% of its text with any other city page. A new city page should stay under about 40%; give it its own ROADS, LOCAL and FAQ text.
