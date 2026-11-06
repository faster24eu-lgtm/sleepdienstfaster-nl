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

## 2026-10-22 – three new kennisbank pages from Search Console gaps
Queries with impressions but no page of their own (GSC to 2026-10-21):
- /kennisbank/auto-slepen-met-touw/ – "mag je een auto slepen met een touw", "mag je slepen op de snelweg", "auto slepen snelweg boete", "slepen op de snelweg" (were landing on pech-op-de-snelweg / elektrische-auto-slepen at pos 38–69).
- /kennisbank/auto-naar-garage-laten-slepen/ – "auto laten slepen naar garage kosten", "auto slepen naar garage kosten", "kosten auto slepen".
- /kennisbank/goedkope-sleepdienst/ – "goedkope sleepdienst voor auto's", "sleepkosten auto" (price-shoppers; "goedkope takeldienst" brought clicks on the Belgian site).
Added %GUIDE_PHRASES for all three, plus manual links from wat-kost-een-sleepdienst, pech-op-de-snelweg, diensten/elektrische-auto-slepen and diensten/sleepdienst. Re-check positions from ~2026-11-12.
=======
## 2026-10-25 – titles matched to Search Console queries
30 days: 1,535 impressions, 3 clicks, avg. position 59; 28 of 74 pages have impressions. Big-city head terms rank 50–80 (authority problem, not on-page). Best positions are niche pages: bestelbus slepen 5.5, elektrische auto slepen 15.6, pech op de snelweg 23.6, caravan transport kosten 28.4, Den Bosch 30.
- Utrecht: title override "Auto sleepdienst Utrecht 24/7 | Auto slepen vanaf €125" (queries "autosleepdienst utrecht" 69, "auto sleepdienst utrecht" 38).
- Amsterdam: "Sleepdienst Amsterdam: auto slepen 24/7, vanaf €125" (queries auto slepen / auto sleepdienst / auto wegslepen amsterdam at 52–78).
- Camper/caravan: title and description answer "wat kost caravan transport" (28.4).
Re-check from ~2026-11-15.

## 2026-10-25 – towns chosen by search volume; indexing is the bottleneck
Keyword Planner (NL, 12 months, "sleepdienst <plaats>"): Rotterdam 390, Amsterdam 320, Utrecht 320, Den Haag 140, Amersfoort 90, Roermond 90, Barendrecht 90, Almere 70, Breda 70, Eindhoven 70, Arnhem 50, Dordrecht 50, Groningen 50, Tilburg 50, Schiedam 40. Most other towns (incl. 50+ candidates tested: Hoorn, Ede, Oss, Zeist, Gorinchem, Spijkenisse …) are under 10/month.
- URL inspection: Den Haag, Amersfoort, Roermond, Almere, Eindhoven, Arnhem and Groningen are "Discovered – currently not indexed" (never crawled). Den Bosch and Breda are indexed. These pages need crawling first, not new text.
- New city pages: Barendrecht (90), Schiedam (40), Purmerend (20), Lelystad (20); max similarity 28 %. Linked from the "near" lists of Rotterdam, Dordrecht, Delft, Amsterdam, Zaandam and Almere.

## 2026-10-28 – cut to cities with demand; truck, EV and snelweg
Search Console 30 Sep – 27 Oct: 2,424 impressions, 5 clicks, avg. position 52. URL inspection: 47 of 80 indexed, 28 "Discovered – currently not indexed", 5 unknown (incl. Dordrecht).
- Deleted 21 city pages that were never indexed and have 0–10 searches/month (Keyword Planner NL, 12 months): Den Helder, Deventer, Emmen, Etten-Leur, Goes, Gouda, Hengelo, Hilversum, Hulst, Moerdijk, Oosterhout, Schiphol, Vlissingen-Middelburg, Waalwijk, Weert, Zevenbergen, Assen, Delft, Heerlen, Helmond, Sittard. 62 pages, 60 in the sitemap (resubmitted).
- Kept the non-indexed cities with demand (Haarlem 40, Dordrecht 50, Zwolle/Zaandam/Venlo/Leiden/Apeldoorn/Alkmaar 30, Maastricht/Leeuwarden/Terneuzen 20). Dordrecht, Haarlem, Leiden and Zwolle added to @FOOT_CITIES, so every page links them; near lists of Den Haag, Amsterdam, Apeldoorn, Lelystad, Enschede, Groningen, Leeuwarden point to them. "sleepdienst leiden" had 58 impressions on the homepage because /sleepdienst/leiden/ is not indexed.
- Truck searches ("vrachtwagen sleepdienst in botlek rotterdam" etc.) were split: Rotterdam page 40 impr. at pos 40, truck page 6 at pos 12. Truck title now names the Rotterdam port; Rotterdam LOCAL links the truck page.
- Elektrische auto slepen (pos 15): short answer box, transport mode, FAQ "mag je een elektrische auto slepen met een touw", lege accu.
- Pech op de snelweg (188 impr., pos 20): short answer box, pechhaven FAQ, link to verkeerd getankt (110 searches/month, not indexed). Fixed FAQ that said rope towing on the motorway is allowed to the first exit; body and the touw guide say it is not.
Re-check indexing and positions from ~2026-11-15.

## 2026-10-29 – Keyword stuffing cut, Amsterdam/Rotterdam expanded (owner approved)
- City link text in the Werkgebied list and the footer is now the place name only ("Rotterdam", not "Sleepdienst Rotterdam"); the province heading and the Werkgebied heading give the context. Werkgebied page: "sleepdienst" 50 → 5 times.
- Homepage: the full 33-city list is replaced by one paragraph linking the 7 biggest cities + the truck service and a button to the Werkgebied page ("sleepdienst" 57 → 13). It ranked for "sleepdienst leiden/zwolle/tiel" at 60+ only because of that list.
- Werkgebied: three regional paragraphs (Randstad, Brabant/Zeeland/zuiden, noord en oost) above the list.
- Amsterdam (+4 LOCAL paragraphs: Zuidoost events, Zuidas garages, Westpoort, EVs) and Rotterdam (+4: bridges/tunnels, Ahoy/Kuip, Spaanse Polder, airport), each + a price FAQ. Similarity now 25% / 24% max (was 36% between them).

## 2026-11-05 – rebuild from Search Console, Keyword Planner and Google results
Search Console, whole life of the site: 12 clicks, 4,258 impressions (Netherlands 3,749). Mobile position 18.2, desktop 53.6. Weekly position 62 → 53 → 32 → 35. 45 % of impressions are truck searches; the truck page ranks 13–18 when Google shows it, town pages 40–85. 48 of 61 pages indexed.
Keyword Planner NL (monthly): pechhulp 4,400; autoambulance 2,900; sleepdienst 2,400; autotransport 2,400; bergingsbedrijf 1,000; auto slepen 480; takeldienst 390; pechhulp zonder abonnement 260; sleepdienst in de buurt 140; vrachtwagen berging 140. Most "sleepdienst <small town>" terms are under 10.
Google.nl, 5 Nov: maps pack on nearly every local search. Organic: Top Sleepdienst (78 town pages, ~2,100 words each), Takeldienst Nederland (389 pages, ~630 words), Sleepdienst XL (115 pages, ~1,400), Destan, plus exact-match domains (sleepdienstroermond.nl, sleepdienstutrecht.nl). All name sleepdienst, takeldienst, pechhulp and autotransport per town. Automeister openly says it brokers ("bemiddelen") and ranks.
Changes: town pages get PECH, TRANSPORT and (where searched) TRUCK sections plus two town FAQs; titles name takeldienst and pechhulp. New: /sleepdienst/ botlek-maasvlakte, vlaardingen, delft, rijswijk, westland, veenendaal, tiel; /diensten/ berging, takeldienst, autoambulance, sleepdienst-in-de-buurt. Truck page retitled for "vrachtwagen berging" with a section naming searched places. Footer links now follow search volume. "Eigen sleepwagens/materieel" wording removed.
Delft was deleted on 2026-10-28 for low volume; restored because Search Console still shows searches and it links Den Haag to Rotterdam. Re-check from ~2026-11-26: positions per page, indexing of the new pages.

## 2026-11-06 (night) – CTR titles/meta wave + sitemap lastmod
Goal: higher CTR on city SERPs (GSC: high impressions, low clicks; many city pages at ~pos 40–50). No invented metrics.

Titles/meta pattern: `Sleepdienst <plaats> 24/7 | ±30 min, prijs vooraf` (+ unique local roads/landmarks in description). Applied to all city pages that still used default `city_seo` titles, plus earlier batch (Amsterdam, Rotterdam, Utrecht, Leiden, Den Haag, Haarlem, Eindhoven, …). Botlek page kept truck angle: `Vrachtwagen sleepdienst Botlek 24/7 | prijs vooraf`.

Also: home/tarieven/pech-op-de-snelweg/autotransport titles earlier same night. Sitemap: every URL now has `<lastmod>YYYY-MM-DD</lastmod>` (build.pl updated). Re-check CTR/positions in Search Console after ~2–3 weeks.

## 2026-11-06 (night, wave A–C) – gids strengthen, linking, thin cities
- Strengthened `/kennisbank/wat-kost-een-sleepdienst/` and `/kennisbank/sleepdienst-zonder-abonnement/` (CTR titles; honest ANWB/zonder-lid angle).
- CTR titles + cross-links on `/diensten/elektrische-auto-slepen/` and `/diensten/bestelbus-slepen/` (pechhulp-hoek).
- Home + Amsterdam/Rotterdam/Botlek: clearer links to Botlek, tarieven, pech-gids, wat-kost.
- `GUIDE_PHRASES`: Botlek/Maasvlakte/Europoort, vrachtwagen sleepdienst, prijs/tarieven → more contextual internal links.
- Local paragraph added on Zoetermeer, Apeldoorn, Enschede, Almere, Zwolle (landmarks/roads only).

## 2026-11-06 (night) – pechhulp CTR, 5 cities LOCAL, diensten index
- `/diensten/pechhulp/`: CTR title/meta/lead + FAQ ANWB/kosten + link wat-kost.
- `/diensten/`: sharper title/description/lead (list hub).
- LOCAL landmark para: Tilburg, Leiden, Leeuwarden, Amersfoort, Haarlem (roads/landmarks only).

## 2026-11-06 (night, late) – LOCAL batch 2 + polish
- LOCAL landmarks: Zaandam, Tiel, Venlo, Rijswijk, Roermond (roads/landmarks only).
- Light CTR: `/contact/`, `/tarieven/` lead (+ wat-kost link), `/over-ons/` lead.
- robots.txt + sitemap present (Allow:/, sitemap URL, lastmod 2026-11-06); rebuild 0 broken links.

## 2026-11-06 (night) – LOCAL batch Alkmaar/Purmerend/Veenendaal/Westland/Vlaardingen
- LOCAL landmark para added (roads/landmarks only, no prices/reviews): Alkmaar (Boekelermeer/N9), Purmerend (A7/Beemster), Veenendaal (A12/Rhenen), Westland (N211/kassen), Vlaardingen (A20/Beneluxtunnel).

## 2026-11-06 (night) – LOCAL batch Lelystad/Schiedam/Barendrecht/Delft/Nijmegen
- LOCAL landmark para (roads/landmarks only): Lelystad (A6/Houtrib), Schiedam (Beneluxtunnel/Kethelplein), Barendrecht (Vaanplein), Delft (A13/TU), Nijmegen (Waalbrug/A73).

## 2026-11-06 (night) – LOCAL remaining thin cities
- Concrete road/landmark LOCAL added: Terneuzen (Westerscheldetunnel), Groningen (A7/A28/ring), Breda (A16/A27/CS), Arnhem (A12/A50/Mandelabrug), Dordrecht (A16/bruggen/Drechttunnel), Den Bosch (A2/A59/Paleiskwartier), Maastricht (A2-tunnel/Maasbruggen).

## 2026-11-06 (night ~03:15) – LOCAL thin finish + section fix
- LOCAL road/landmark added: Roosendaal (A17/A58/Outlet), Eindhoven (A2/A67/Airport), Den Haag (A12/A4/Scheveningen), Amsterdam (A10/Coentunnel), Utrecht (A2/A12/Rijnsweerd).
- Moved misplaced landmark paras into LOCAL block: Westland, Vlaardingen, Delft, Veenendaal (sources+HTML).

## 2026-11-06 (night ~03:30) – indexing: similarity + crawl paths
- Ran `check_similarity.pl`: worst cluster Tilburg↔Zwolle was ~47% max-sim / ~20% unique. Rewrote LOCAL/FAQ/PECH/TRANSPORT for Tilburg, Zwolle, Groningen (+ light Breda/Maastricht). Result: all city max-sim ≤36%, no pair ≥40%.
- Crawl paths: expanded `@FOOT_CITIES` (+Groningen, Maastricht, Nijmegen, Alkmaar, Terneuzen, Den Bosch, Delft); home werkgebied prose; kennisbank + diensten hub body links to underlinked cities; Terneuzen added to near of Bergen-op-Zoom/Roosendaal/Breda; Maastricht to Roermond/Venlo/Den Bosch near.
- Technical: no noindex/canonical-to-home on cities; robots Allow:/ + sitemap; sitemap 73 URLs / 40 cities; html lang=nl; unique canonicals. Build 0 broken links.

## 2026-11-06 (night ~03:30) – mid-sim PECH + near-graph
- Compacted shared city auto-FAQ answers in `build.pl` (masked city name = pure shared shingles).
- Rewrote PECH with local angle for mid-sim cities: Den Bosch, Arnhem, Amersfoort, Apeldoorn, Leiden, Zoetermeer, Nijmegen, Enschede, Dordrecht, Roosendaal, Leeuwarden, Haarlem, Alkmaar (skipped already-shipped Tilburg/Zwolle/Groningen/Breda/Maastricht).
- Near-inbound: Leeuwarden 1→5, Lelystad 2→6, Purmerend 1→6 (plus Enschede/Apeldoorn cross-links).
- `check_similarity.pl` after: max-sim **33%** (was 36%).

## 2026-11-06 (night ~03:35) – EN Pernis/Europoort sync + TRANSPORT mid-sim
- Janssen EN: synced `/en/sleepdienst-pernis/` and `/en/sleepdienst-europoort/` to distinct NL angles; fixed Delfshaven EN road Dutch leak (“Verbindingen”→“Links”).
- Faster: TRANSPORT uniqueness pass on Dordrecht/Roosendaal, Den Bosch/Arnhem, Nijmegen/Zwolle, Amersfoort/Apeldoorn, Leiden/Zoetermeer, Alkmaar. `check_similarity.pl` max-sim still **33%** (shared hero/FAQ chrome floors further drops).

## 2026-11-06 (night) – city FAQ Wat-kost rotate; max-sim 33%→31%
- Shared auto-FAQ "Wat kost een sleepdienst in …?" now rotates 3 short no-price answers by slug length+checksum (alongside existing goedkope rotate). Re-ran check_similarity.pl: global max-sim 31% (haarlem↔amersfoort); amersfoort↔apeldoorn 30%.

## 2026-11-06 (night) – twitter:image on Faster
- Added twitter:card=summary_large_image + twitter:image (same as og:image faster-road-transport.jpg) in build.pl and existing HTML.

## 2026-11-06 (night) – www/apex OK; OG dims/alt; schema tel E.164
- Live www→apex 301; CNAME=apex. OG width/height/alt + twitter:image:alt (1600×1200). JSON-LD telephone E.164.

## 2026-11-06 (night) – image weight; hub city links; footer crawl
- Compressed gallery/hero JPGs (progressive): road-transport 210→186KB (q80); intervention 141→125KB (q80); warehouse 177→119KB (q75). Dims unchanged.
- Werkgebied hub prose: city names → internal links (Randstad/Brabant/noord-oost). Footer +6 cities (Schiedam, Zoetermeer, Vlaardingen, Venlo, Arnhem, Enschede).
- Sitemap crawl: 73/73 HTTP 200, no soft-404s; reverse orphan crawl clean.

## 2026-11-06 (night) – WebP picture/srcset; 404 polish
- Added WebP companions (q~80–82): road 186→138KB webp; intervention 125→95KB; warehouse 119→93KB. On-page heroes/gallery use `<picture><source type=image/webp>`. **og:image / twitter:image stay JPG**.
- 404: clearer copy + links homepage/werkgebied/contact/diensten/tarieven.

## 2026-11-06 (night) – responsive srcset (800/1200)
- Added width variants: road/intervention `-800`/`-1200` JPG+WebP; warehouse `-600` (orig 738px, no upscale). `<picture>` srcset+sizes on hero/gallery. og:image remains full JPG.

## 2026-11-06 (night) – LCP / CWV preload + fetchpriority
- Home + city heroes: `loading="eager" fetchpriority="high" decoding="async"` on LCP `<img>` (gallery stays `loading="lazy" decoding="async"`).
- `<link rel="preload" as="image" type="image/webp" imagesrcset=… imagesizes=…>` for the hero WebP (800/1200/full) so mobile can pick 800w; desktop not forced to 800. **og:image stays full JPG.**
- Breda/Bergen-op-Zoom heroes preload `faster-intervention-workshop-*.webp` (their hero image).

## 2026-11-06 (night) – MORNING 08:00 DIGEST (mention these)
Facts only from shipped work tonight:
- **CTR titles/meta** on city + hub pages (`Sleepdienst <plaats> 24/7 | ±30 min, prijs vooraf`); descriptions with local roads/landmarks.
- **LOCAL uniqueness** + PECH/TRANSPORT rewrites; `check_similarity.pl` max-sim down to ~31%.
- **www → apex 301** OK; CNAME apex; canonicals apex.
- **OG/Twitter**: `faster-road-transport.jpg` + width/height/alt (1600×1200); og:image not WebP.
- **CWV images**: compressed JPG; WebP companions; responsive **srcset 800/1200** (+ warehouse 600); `<picture>`; LCP **preload + fetchpriority=high**.
- **Custom 404**; sitemap with lastmod; crawl paths/footer hubs expanded.
- **No** Faster EN mirror this wave; **no** invented GSC numbers — re-check CTR/positions in GSC after ~2–3 weeks.

## 2026-11-06 (night) – CWV measured (Lighthouse mobile)
PSI API: **HTTP 429**. Local Lighthouse 13.6 mobile simulate:
- `/`: perf **100**, LCP **1.1s**, CLS **0**, TBT **10ms**
- `/sleepdienst/amsterdam/`: perf **100**, LCP **0.9s**, CLS **0**, TBT **0ms**
No further image/CSS/JS surgery — already WebP+srcset+LCP preload; CSS ~15KB, JS ~0.7KB defer. Unsized images: none.
