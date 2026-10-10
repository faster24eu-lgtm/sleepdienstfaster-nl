#!/usr/bin/perl
# Site builder for sleepdienstfaster.nl
#
#   perl _build/build.pl
#
# Reads every _build/pages/**/*.page file and writes the matching page:
#   index.page            -> index.html
#   404.page              -> 404.html
#   sleepdienst/breda.page -> sleepdienst/breda/index.html
# wrapped in the shared head, header, breadcrumbs, footer and scripts.
# Also writes sitemap.xml and robots.txt, and reports broken internal links.
#
# .page format: "key: value" lines, then sections that start with a line
# "===NAME===". Every section becomes a field (lower case name).
#   title, description   meta tags (title is used as-is)
#   h1                    page heading (template city/page)
#   label                 breadcrumb label and link text in lists
#   crumbs                "Label|path/ > Label|path/" between Home and this page
#   template              city | page | raw (raw: MAIN is the whole <main>)
#   card                  one-line summary for hub lists
#   kind                  city | dienst | gids   (used by {{LIST:kind}})
#   province              city pages: grouping in the werkgebied list
#   near                  city pages: slugs of nearby city pages, comma separated
#   sitemap: no           leave out of sitemap
# Sections: MAIN (page body), FAQ ("V: ..." / "A: ..." lines), and for city
# pages LEAD, ROADS, LOCAL, ROUTE.
#
# Placeholders: {{R}} (relative path to the site root), {{PHONE}},
# {{PHONE_HREF}}, {{WA_HREF}}, {{PRICE}}, {{LIST:kind}}, {{FORM}},
# {{REVIEWS}}, {{STEPS}}, {{CTA}}
use strict;
use warnings;
use utf8;
use File::Find;
use File::Path qw(make_path);
use File::Basename qw(dirname);

# ---------------------------------------------------------------- settings
# PREVIEW = 1: every page gets noindex and robots.txt blocks crawling.
# Set to 0 only when the site runs on its own domain and is ready to launch.
my $PREVIEW    = 1;
my $BASE       = 'https://sleepdienstfaster.nl';
my $NAME       = 'Sleepdienst Faster';
my $PHONE      = '+32 3 375 67 37';
my $PHONE_HREF = 'tel:+3233756737';
my $WA_NUM     = '3233756737';
my $WA_TEXT    = 'Hallo%20Faster%2C%20ik%20heb%20een%20sleepdienst%20nodig.%20Mijn%20locatie%3A%20';
my $WA_HREF    = "https://wa.me/$WA_NUM?text=$WA_TEXT";
my $FORM_TO    = 'faster24eu@gmail.com';     # formsubmit.co, same as takeldienstfaster.be
my $PRICE      = '125';

my @NAV = (
  ['Werkgebied',          'sleepdienst/'],
  ['Diensten',            'diensten/'],
  ['Tarieven',            'tarieven/'],
  ['Pech op de snelweg',  'kennisbank/pech-op-de-snelweg/'],
  ['Over ons',            'over-ons/'],
  ['Contact',             'contact/'],
);
my @FOOT_CITIES = qw(rotterdam amsterdam den-haag utrecht eindhoven breda tilburg den-bosch);
my @FOOT_INFO = (['Tarieven','tarieven/'],['Kennisbank','kennisbank/'],['Over ons','over-ons/'],['Contact','contact/'],['Privacy','privacy/']);

my @REVIEWS = (
  ['Portsurmer', 'Op zondag pech gehad in Breda en meteen geholpen. Snelle, professionele en vriendelijke takeldienst. Bedankt!!'],
  ['TheRealM', 'Super snel opkomen dagen en de prijs was zoals afgesproken, geen gefoefel.'],
  ['nabil Choukair', 'Perfecte service. Staat zelf klaar om 1u \'s nachts. Was binnen de 20 min aanwezig. En nog voor een goede prijs.'],
  ['Karen Vardanyan', 'Iemand die zijn job goed kent, zeer vriendelijke chauffeur, professioneel geholpen, bedankt om snel te zijn'],
  ['Marko Gheis', 'Ik stond stil op de snelweg, het was zeer gevaarlijk met mijn vrouw en kinderen. Was heel snel ter plaatse en de goedkoopste die er was op dat moment.'],
  ['Alattim Tokmak', 'Zeer tevreden, binnen de 15 minuten waren ze al aanwezig en qua prijs is dit gewoon de max!!! Zeker een aanrader!!!'],
);

# ---------------------------------------------------------------- read pages
my $root = dirname(dirname(__FILE__));
chdir $root or die "chdir $root: $!";

my %P;
find(sub {
  return unless /\.page$/;
  my $src = $File::Find::name;
  (my $rel = $src) =~ s{^_build/pages/}{};
  $rel =~ s/\.page$//;
  my $out = $rel eq 'index' ? 'index.html'
          : $rel eq '404'   ? '404.html'
          : $rel =~ m{(.*)/index$} ? "$1/index.html"
          : "$rel/index.html";
  (my $url = $out) =~ s{index\.html$}{};
  open my $fh, '<:encoding(UTF-8)', $_ or die "$src: $!";
  local $/; my $t = <$fh>; close $fh;
  $t =~ s/\r\n/\n/g;
  my @parts = split /^===([A-Z]+)===\n/m, $t;
  my %p = (src => $src, out => $out, url => $url, slug => (split m{/}, $rel)[-1]);
  for (split /\n/, shift @parts) { $p{$1} = $2 if /^(\w+):\s*(.*?)\s*$/ }
  while (@parts) { my ($k, $v) = splice @parts, 0, 2; $v =~ s/\s+$//; $p{lc $k} = $v }
  $p{template} //= ($p{kind} // "") eq "city" ? "city" : "page";
  $p{crumbs} //= "Werkgebied|sleepdienst/" if ($p{kind} // "") eq "city";
  for (qw(title description label)) { warn "$src: no $_\n" unless $p{$_} }
  $P{$out} = \%p;
}, '_build/pages');

my %BYSLUG;   # "sleepdienst/breda" style keys for near links
for my $p (values %P) { (my $k = $p->{url}) =~ s{/$}{}; $BYSLUG{$k} = $p }

# ---------------------------------------------------------------- helpers
sub esc { my $s = shift // ''; $s =~ s/&(?!\w+;|#\d+;)/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s =~ s/"/&quot;/g; $s }
sub jstr { my $s = shift // ''; $s =~ s/<[^>]+>//g; $s =~ s/&nbsp;/ /g; $s =~ s/&amp;/&/g; $s =~ s/&euro;/€/g; $s =~ s/\\/\\\\/g; $s =~ s/"/\\"/g; $s =~ s/\n/ /g; $s }

sub faq_items {
  my $f = shift // return ();
  my @out; my ($q, $a);
  for my $line (split /\n/, $f) {
    if ($line =~ /^V:\s*(.*)/) { push @out, [$q, $a] if $q; ($q, $a) = ($1, '') }
    elsif ($line =~ /^A:\s*(.*)/) { $a = $1 }
    elsif ($line =~ /\S/ && defined $a) { $a .= " $line" }
  }
  push @out, [$q, $a] if $q;
  @out;
}

sub faq_html {
  my @f = @_;
  return '' unless @f;
  my $h = qq{<section class="section"><div class="container narrow"><h2>Veelgestelde vragen</h2><div class="faq">};
  $h .= qq{<details><summary>$_->[0]</summary><div class="faq-a"><p>$_->[1]</p></div></details>} for @f;
  $h . qq{</div></div></section>};
}

sub list_html {
  my ($kind) = @_;
  my @ps = sort { ($a->{order} // 50) <=> ($b->{order} // 50) || $a->{label} cmp $b->{label} } grep { ($_->{kind} // '') eq $kind } values %P;
  if ($kind eq 'city') {
    my %g; push @{ $g{$_->{province} // 'Overig'} }, $_ for @ps;
    my $h = '<div class="province-grid">';
    for my $prov (sort keys %g) {
      $h .= qq{<div class="province"><h3>$prov</h3><ul>};
      $h .= qq{<li><a href="{{R}}$_->{url}">Sleepdienst $_->{label}</a></li>} for @{ $g{$prov} };
      $h .= '</ul></div>';
    }
    return "$h</div>";
  }
  my $h = '<div class="card-grid">';
  $h .= qq{<a class="card" href="{{R}}$_->{url}"><h3>$_->{label}</h3><p>} . ($_->{card} // '') . qq{</p><span class="more">Lees meer &rarr;</span></a>} for @ps;
  "$h</div>";
}

sub reviews_html {
  my ($start) = @_; $start //= 0;
  my $h = qq{<section class="section grey"><div class="container"><div class="section-head"><h2>Wat klanten zeggen</h2><p>Echte Google-reviews van klanten van Faster.</p></div><div class="review-grid">};
  for my $i (0..2) {
    my $r = $REVIEWS[($start + $i) % @REVIEWS];
    $h .= qq{<figure class="review"><div class="stars" aria-label="5 sterren">★★★★★</div><blockquote>&ldquo;$r->[1]&rdquo;</blockquote><figcaption>$r->[0] &middot; Google review</figcaption></figure>};
  }
  $h . '</div></div></section>';
}

my $STEPS = <<'H';
<section class="section"><div class="container"><div class="section-head"><h2>Zo werkt het</h2><p>Geen abonnement, geen lidmaatschap. U betaalt alleen voor de rit die u nodig heeft.</p></div>
<ol class="steps">
<li><strong>Bel of WhatsApp</strong><span>Vertel waar de auto staat, wat er aan de hand is en waar hij naartoe moet.</span></li>
<li><strong>Prijs vooraf</strong><span>U hoort vooraf wat de rit kost. Pas als u akkoord bent, gaat de sleepwagen rijden.</span></li>
<li><strong>Ophalen</strong><span>De auto gaat op het plateau en wordt vastgezet.</span></li>
<li><strong>Afleveren</strong><span>Naar uw garage, uw huis of een ander adres dat u kiest.</span></li>
</ol></div></section>
H

my $CTA = <<'H';
<section class="cta-band"><div class="container cta-inner"><div><h2>Staat uw auto stil?</h2><p>Bel of stuur een WhatsApp met uw locatie. Dag en nacht bereikbaar.</p></div><div class="cta-actions"><a class="btn btn-dark" href="{{PHONE_HREF}}">Bel {{PHONE}}</a> <a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp</a></div></div></section>
H

sub form_html {
  return <<"H";
<form class="quote-form" action="https://formsubmit.co/$FORM_TO" method="POST">
<input type="hidden" name="_subject" value="Aanvraag sleepdienstfaster.nl">
<input type="hidden" name="_next" value="$BASE/bedankt/">
<input type="hidden" name="_captcha" value="false">
<input type="text" name="_honey" class="hp" tabindex="-1" autocomplete="off">
<label>Naam*<input name="naam" required autocomplete="name"></label>
<label>Telefoonnummer*<input name="telefoon" type="tel" required autocomplete="tel"></label>
<label>Waar staat de auto? (adres, plaats of hectometerpaaltje)*<input name="ophaallocatie" required></label>
<label>Waar moet de auto naartoe?<input name="bestemming"></label>
<label>Merk en model<input name="voertuig"></label>
<label>Wat is er gebeurd?<textarea name="bericht" rows="3"></textarea></label>
<button class="btn" type="submit">Vraag een prijs aan</button>
<p class="form-note">Spoed? Bel of WhatsApp ons, dat is sneller dan het formulier.</p>
</form>
H
}

# ---------------------------------------------------------------- templates
sub city_main {
  my $p = shift;
  my $n = $p->{label};
  $p->{img} //= "faster-road-transport.jpg";
  $p->{imgalt} //= "Gele sleepwagen van Faster met een auto op het plateau";
  my $near = '';
  if ($p->{near}) {
    my @l = map { my $q = $BYSLUG{"sleepdienst/$_"}; $q ? qq{<a href="{{R}}$q->{url}">$q->{label}</a>} : do { warn "$p->{src}: near $_ unknown\n"; () } } split /\s*,\s*/, $p->{near};
    $near = '<p class="near">In de buurt: ' . join(' &middot; ', @l) . '</p>' if @l;
  }
  return <<"H";
<section class="hero hero-sub"><div class="container hero-grid">
<div><span class="eyebrow">Sleepdienst $n &middot; 24/7</span><h1>$p->{h1}</h1><div class="lead">$p->{lead}</div>
<div class="hero-actions"><a class="btn" href="{{PHONE_HREF}}">Bel {{PHONE}}</a><a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp uw locatie</a></div>
<ul class="usp"><li>Prijs vooraf, vanaf &euro;{{PRICE}}</li><li>Geen abonnement nodig</li><li>Naar elk adres dat u kiest</li></ul></div>
<figure class="hero-media"><img src="{{R}}assets/img/$p->{img}" alt="$p->{imgalt}" width="1600" height="1200" loading="eager"></figure>
</div></section>
<section class="section"><div class="container two-col"><div class="prose">
<h2>Wegen en knelpunten rond $n</h2>$p->{roads}
<h2>Goed om te weten in $n</h2>$p->{local}
</div><aside class="side">
<div class="price-card"><span>Sleepdienst $n</span><strong>vanaf &euro;{{PRICE}}</strong><p>De vaste prijs hoort u vooraf aan de telefoon. Daarna geen verrassingen.</p><a class="btn" href="{{PHONE_HREF}}">Bel {{PHONE}}</a><a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp</a></div>
</aside></div></section>
{{STEPS}}
{{REVIEWS}}
<section class="section"><div class="container narrow">$near<p><a href="{{R}}sleepdienst/">Bekijk het hele werkgebied &rarr;</a></p></div></section>
H
}

sub page_main {
  my $p = shift;
  my $intro = $p->{lead} ? qq{<div class="lead">$p->{lead}</div>} : '';
  return <<"H";
<section class="page-head"><div class="container narrow"><h1>$p->{h1}</h1>$intro</div></section>
$p->{main}
H
}

# ---------------------------------------------------------------- layout
sub nav_html {
  my $p = shift;
  join '', map { my $cur = index($p->{url}, $_->[1]) == 0 ? ' aria-current="page"' : ''; qq{<a href="{{R}}$_->[1]"$cur>$_->[0]</a>} } @NAV;
}

sub crumbs {
  my $p = shift;
  return ('', '') if $p->{url} eq '' || ($p->{crumbs} // '') eq 'none';
  my @c = (['Home', '']);
  push @c, map { [split /\|/] } split /\s*>\s*/, $p->{crumbs} if $p->{crumbs};
  push @c, [$p->{label}, $p->{url}];
  my $html = '<nav class="crumbs container" aria-label="Kruimelpad">' . join(' <span>/</span> ', map { $_ == $#c ? "<span>$c[$_][0]</span>" : qq{<a href="{{R}}$c[$_][1]">$c[$_][0]</a>} } 0..$#c) . '</nav>';
  my $i = 0;
  my $ld = '{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[' . join(',', map { $i++; qq{{"\@type":"ListItem","position":$i,"name":"} . jstr($_->[0]) . qq{","item":"$BASE/$_->[1]"}} } @c) . ']}';
  return ($html, qq{<script type="application/ld+json">$ld</script>});
}

sub business_ld {
  my $p = shift;
  my $area = $p->{kind} && $p->{kind} eq 'city' ? qq{{"\@type":"City","name":"} . jstr($p->{label}) . qq{"}} : '{"@type":"Country","name":"Nederland"}';
  return qq{<script type="application/ld+json">{"\@context":"https://schema.org","\@type":"AutomotiveBusiness","name":"$NAME","url":"$BASE/","telephone":"$PHONE","image":"$BASE/assets/img/faster-road-transport.jpg","priceRange":"vanaf €$PRICE","openingHours":"Mo-Su 00:00-23:59","areaServed":$area}</script>};
}

my $year = 1900 + (localtime)[5];
my @written;
for my $out (sort keys %P) {
  my $p = $P{$out};
  my $depth = () = $out =~ m{/}g;
  my $R = $out eq '404.html' ? '/' : '../' x $depth;

  my $main = $p->{template} eq 'city' ? city_main($p)
           : $p->{template} eq 'raw'  ? $p->{main}
           : page_main($p);
  my @faq = faq_items($p->{faq});
  $main .= faq_html(@faq);
  $main .= $CTA unless ($p->{cta} // '') eq 'no';

  my ($crumb_html, $crumb_ld) = crumbs($p);
  my $faq_ld = @faq ? '<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' . join(',', map { qq{{"\@type":"Question","name":"} . jstr($_->[0]) . qq{","acceptedAnswer":{"\@type":"Answer","text":"} . jstr($_->[1]) . qq{"}}} } @faq) . ']}</script>' : '';
  my $biz = ($p->{url} eq '' || ($p->{kind} // '') eq 'city' || $p->{url} eq 'contact/') ? business_ld($p) : '';
  my $robots = $PREVIEW || ($p->{robots} // '') eq 'noindex' ? '<meta name="robots" content="noindex, nofollow">' : '';
  my $canon = "$BASE/$p->{url}";
  my $title = esc($p->{title});
  my $desc = esc($p->{description});
  my $nav = nav_html($p);
  my $foot_cities = join '', map { my $q = $BYSLUG{"sleepdienst/$_"}; $q ? qq{<a href="{{R}}$q->{url}">Sleepdienst $q->{label}</a>} : () } @FOOT_CITIES;
  my $foot_dien = join '', map { qq{<a href="{{R}}$_->{url}">$_->{label}</a>} } sort { ($a->{order} // 50) <=> ($b->{order} // 50) } grep { ($_->{kind} // '') eq 'dienst' } values %P;
  my $foot_info = join '', map { qq{<a href="{{R}}$_->[1]">$_->[0]</a>} } @FOOT_INFO;

  my $html = <<"H";
<!doctype html>
<html lang="nl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<meta name="description" content="$desc">
$robots
<link rel="canonical" href="$canon">
<meta property="og:type" content="website">
<meta property="og:locale" content="nl_NL">
<meta property="og:site_name" content="$NAME">
<meta property="og:title" content="$title">
<meta property="og:description" content="$desc">
<meta property="og:url" content="$canon">
<meta property="og:image" content="$BASE/assets/img/faster-road-transport.jpg">
<link rel="icon" href="{{R}}favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="32x32" href="{{R}}assets/img/favicon-32.png">
<link rel="apple-touch-icon" href="{{R}}assets/img/apple-touch-icon.png">
<link rel="stylesheet" href="{{R}}assets/css/styles.css">
$biz$crumb_ld$faq_ld
</head>
<body>
<header class="site-header"><div class="container nav-wrap">
<a class="brand" href="{{R}}"><span class="brand-mark">F</span><span class="brand-text"><strong>FASTER</strong><small>SLEEPDIENST 24/7</small></span></a>
<nav class="main-nav" id="main-nav" aria-label="Hoofdmenu">$nav</nav>
<div class="nav-actions"><a class="btn btn-wa btn-small" href="{{WA_HREF}}">WhatsApp</a><a class="btn btn-small" href="{{PHONE_HREF}}">Bel 24/7</a><button class="menu-toggle" type="button" aria-controls="main-nav" aria-expanded="false">Menu</button></div>
</div></header>
$crumb_html
<main>
$main
</main>
<footer class="site-footer"><div class="container footer-grid">
<div><a class="brand" href="{{R}}"><span class="brand-mark">F</span><span class="brand-text"><strong>FASTER</strong><small>SLEEPDIENST 24/7</small></span></a>
<p>Sleepdienst en autotransport in heel Nederland. Dag en nacht bereikbaar.</p>
<p><a href="{{PHONE_HREF}}">{{PHONE}}</a><a href="{{WA_HREF}}">WhatsApp</a></p></div>
<div><h3>Werkgebied</h3>$foot_cities<a href="{{R}}sleepdienst/">Alle plaatsen</a></div>
<div><h3>Diensten</h3>$foot_dien</div>
<div><h3>Informatie</h3>$foot_info</div>
</div><div class="container footer-bottom"><span>&copy; $year Faster</span><span>Prijzen inclusief btw, tenzij anders vermeld.</span></div></footer>
<div class="mobile-bar"><a href="{{PHONE_HREF}}">Bel nu</a><a class="wa" href="{{WA_HREF}}">WhatsApp</a></div>
<script src="{{R}}assets/js/main.js" defer></script>
</body>
</html>
H

  # placeholders (repeat: inserted blocks contain placeholders too)
  for (1..3) {
    $html =~ s/\{\{LIST:(\w+)\}\}/list_html($1)/ge;
    $html =~ s/\{\{REVIEWS\}\}/reviews_html($p->{reviews} \/\/ 0)/ge;
    $html =~ s/\{\{STEPS\}\}/$STEPS/g;
    $html =~ s/\{\{CTA\}\}/$CTA/g;
    $html =~ s/\{\{FORM\}\}/form_html()/ge;
  }
  $html =~ s/\{\{R\}\}/$R/g;
  $html =~ s/\{\{PHONE_HREF\}\}/$PHONE_HREF/g;
  $html =~ s/\{\{PHONE\}\}/$PHONE/g;
  $html =~ s/\{\{WA_HREF\}\}/$WA_HREF/g;
  $html =~ s/\{\{PRICE\}\}/$PRICE/g;
  $html =~ s/\n{2,}/\n/g;
  warn "$p->{src}: unreplaced $1\n" while $html =~ /(\{\{[A-Z_:a-z]+\}\})/g;

  make_path(dirname($out)) if $out =~ m{/};
  open my $fh, '>:encoding(UTF-8)', $out or die "$out: $!";
  print $fh $html; close $fh;
  push @written, $out;
}

# ---------------------------------------------------------------- sitemap, robots
open my $sm, '>:encoding(UTF-8)', 'sitemap.xml' or die;
print $sm qq{<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n};
for my $p (sort { $a->{url} cmp $b->{url} } values %P) {
  next if $p->{out} eq '404.html' || ($p->{sitemap} // '') eq 'no';
  print $sm "  <url><loc>$BASE/$p->{url}</loc></url>\n";
}
print $sm "</urlset>\n"; close $sm;

open my $rb, '>', 'robots.txt' or die;
print $rb $PREVIEW ? "User-agent: *\nDisallow: /\n" : "User-agent: *\nAllow: /\n\nSitemap: $BASE/sitemap.xml\n";
close $rb;

# ---------------------------------------------------------------- link check
my $bad = 0;
for my $out (@written) {
  open my $fh, '<:encoding(UTF-8)', $out or die; local $/; my $h = <$fh>; close $fh;
  my $dir = $out =~ m{^(.*)/} ? "$1/" : '';
  while ($h =~ /(?:href|src)="([^"#?]*)/g) {
    my $l = $1;
    next if $l eq '' || $l =~ m{^(https?:|mailto:|tel:|//)};
    my $t = $l =~ m{^/} ? substr($l, 1) : "$dir$l";
    1 while $t =~ s{(^|/)(?!\.\./)[^/]+/\.\./}{$1};
    $t .= 'index.html' if $t eq '' || $t =~ m{/$};
    unless (-e $t) { print "BROKEN in $out: $l\n"; $bad++ }
  }
}
printf "%d pages, %d broken links%s\n", scalar @written, $bad, $PREVIEW ? ' (PREVIEW: noindex on)' : '';
