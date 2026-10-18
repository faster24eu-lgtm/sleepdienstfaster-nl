#!/usr/bin/perl
# Site builder for sleepdienstfaster.nl
#
#   perl _build/build.pl
#
# Reads every _build/pages/**/*.page file and writes the matching page:
#   index.page             -> index.html
#   404.page               -> 404.html
#   sleepdienst/breda.page -> sleepdienst/breda/index.html
# wrapped in the shared head, header, breadcrumbs, footer and scripts.
# Also writes sitemap.xml and robots.txt, and reports broken internal links.
#
# .page format: "key: value" lines, then sections that start with a line
# "===NAME===". Every section becomes a field (lower case name).
#   title, description   meta tags (city pages: generated, see city_seo)
#   h1, h1b               heading; h1b is the yellow second line (optional)
#   label                 breadcrumb label and link text in lists
#   crumbs                "Label|path/ > Label|path/" between Home and this page
#   template              city | page | raw   (raw: MAIN is the whole <main>)
#   card                  one-line summary for hub lists
#   kind                  city | dienst | gids   (used by {{LIST:kind}})
#   province, near        city pages: grouping, and slugs of nearby cities
#   sitemap: no           leave out of sitemap
# Sections: MAIN, FAQ ("V: ..." / "A: ..." lines), and for city pages
# LEAD (first paragraph of the info block), ROADS, LOCAL.
#
# Placeholders: {{R}} {{PHONE}} {{PHONE_HREF}} {{WA_HREF}} {{PRICE}}
# {{HERO}} {{USPS}} {{STEPS}} {{GALLERY}} {{SAFETY}} {{REVIEWS}} {{CTA}}
# {{FORM}} {{LIST:kind}}
use strict;
use warnings;
use utf8;
use File::Find;
use File::Path qw(make_path);
use File::Basename qw(dirname);
binmode STDOUT, ":encoding(UTF-8)";

# ---------------------------------------------------------------- settings
# PREVIEW = 1: every page gets noindex and robots.txt blocks crawling.
# Set to 0 only when the site runs on its own domain and is ready to launch.
my $PREVIEW    = 0;
my $BASE       = 'https://sleepdienstfaster.nl';
my $NAME       = 'Sleepdienst Faster';
my $PHONE      = '+31 97 010229095';
my $PHONE_HREF = 'tel:+3197010229095';
my $WA_NUM     = '3197010229095';
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

# Real Google reviews of Faster: [name, text, tag]
my @REVIEWS = (
  ['Alattim Tokmak', 'Zeer tevreden, binnen de 15 minuten waren ze al aanwezig en qua prijs is dit gewoon de max!!! Zeker een aanrader!!!', 'Goede prijs'],
  ['nabil Choukair', 'Perfecte service. Staat zelf klaar om 1u &rsquo;s nachts. Was binnen de 20 min aanwezig. En nog voor een goede prijs.', ''],
  ['Portsurmer', 'Op zondag pech gehad in Breda en meteen geholpen. Snelle, professionele en vriendelijke takeldienst. Bedankt!!', ''],
  ['Marko Gheis', 'Ik stond stil op de snelweg, het was zeer gevaarlijk met mijn vrouw en kinderen. Was heel snel ter plaatse en de goedkoopste die er was op dat moment.', ''],
  ['Вит Ше', 'Ik was absoluut perfect geholpen door een uiterst vriendelijke en aangename chauffeur. Het was ook zeer goed door dispatch georganiseerd en de prijs viel ook mee.', 'Redelijke prijs'],
  ['TheRealM', 'Super snel opkomen dagen en de prijs was zoals afgesproken, geen gefoefel.', ''],
  ['Karen Vardanyan', 'Iemand die zijn job goed kent, zeer vriendelijke chauffeur, professioneel geholpen, bedankt om snel te zijn 👍', 'Goede prijs'],
  ['Chayden Van Harneveldt', 'Zeer tevreden, zeer goede service.', ''],
);

my $GOOGLE_G = '<svg class="g-logo" viewBox="0 0 48 48" aria-hidden="true"><path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.8 2.4 30.3 0 24 0 14.6 0 6.6 5.4 2.7 13.3l7.9 6.1C12.5 13.6 17.8 9.5 24 9.5z"/><path fill="#4285F4" d="M46.1 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.4c-.5 2.9-2.2 5.3-4.6 7l7.5 5.8c4.4-4 6.8-10 6.8-17.3z"/><path fill="#FBBC05" d="M10.5 28.6c-.5-1.4-.8-3-.8-4.6s.3-3.2.8-4.6l-7.9-6.1C1 16.5 0 20.1 0 24s1 7.5 2.7 10.7l7.8-6.1z"/><path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.5-5.8c-2.1 1.4-4.8 2.3-8.4 2.3-6.2 0-11.5-4.1-13.4-9.8l-7.9 6.1C6.6 42.6 14.6 48 24 48z"/></svg>';

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
  if (($p{kind} // '') eq 'city') { $p{template} //= 'city'; $p{crumbs} //= 'Werkgebied|sleepdienst/'; city_seo(\%p) }
  $p{template} //= 'page';
  for (qw(title description label)) { warn "$src: no $_\n" unless $p{$_} }
  $P{$out} = \%p;
}, '_build/pages');

my %BYSLUG;
for my $p (values %P) { (my $k = $p->{url}) =~ s{/$}{}; $BYSLUG{$k} = $p }

# City pages share one title / description / hero formula so every page
# targets "sleepdienst <plaats>" the same way. "tlabel" is a shorter name
# for the title when the label is long.
sub city_seo {
  my $p = shift;
  my $n = $p->{label};
  my $t = $p->{tlabel} // $n;
  my $title = "Sleepdienst $t 24/7 | Snel ter plaatse, vanaf €$PRICE";
  $title = "Sleepdienst $t 24/7 | Vanaf €$PRICE" if length $title > 62;
  $p->{title} //= $title;
  $p->{description} //= "Auto stuk in $n? Sleepdienst Faster is vaak binnen 30 minuten bij u. 24/7, vaste prijs vooraf vanaf €$PRICE, geen abonnement. Bel of WhatsApp nu.";
  $p->{h1}  //= "Sleepdienst $n";
  $p->{h1b} //= 'binnen 30 minuten*, prijs vooraf.';
  $p->{eyebrow} //= "24/7 &middot; geen abonnement &middot; vanaf &euro;$PRICE";
  $p->{sub} //= "Auto stuk in $n? Bel nu. Een sleepwagen komt naar u toe, en u hoort de prijs voordat iemand vertrekt.";
  $p->{intro} //= "Geen lidmaatschap, geen verrassing achteraf. Wij laden de auto op het plateau en brengen hem naar uw garage, naar huis of naar het adres dat u noemt.";
}

# ---------------------------------------------------------------- helpers
sub esc { my $s = shift // ''; $s =~ s/&(?!\w+;|#\d+;)/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s =~ s/"/&quot;/g; $s }
sub jstr { my $s = shift // ''; $s =~ s/<[^>]+>//g; $s =~ s/&nbsp;/ /g; $s =~ s/&amp;/&/g; $s =~ s/&euro;/€/g; $s =~ s/&rsquo;/’/g; $s =~ s/&#39;/'/g; $s =~ s/\\/\\\\/g; $s =~ s/"/\\"/g; $s =~ s/\n/ /g; $s }

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
  my $h = qq{<section class="section white"><div class="container"><div class="section-head"><div><span class="eyebrow">Veelgestelde vragen</span><h2>Antwoorden voordat u belt</h2></div></div><div class="faq">};
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
  my $h = '<div class="card-grid">'; my $i = 0;
  for (@ps) { $i++; $h .= sprintf qq{<a class="card" href="{{R}}$_->{url}"><span class="num">%02d</span><h3>$_->{label}</h3><p>%s</p><span class="more">Meer info &rarr;</span></a>}, $i, $_->{card} // '' }
  "$h</div>";
}

sub review_card {
  my ($r, $cls) = @_;
  my $tag = $r->[2] ? " &middot; $r->[2]" : '';
  qq{<figure class="review$cls"><div class="review-top">$GOOGLE_G<span class="stars" aria-label="5 sterren">★★★★★</span></div><blockquote>&ldquo;$r->[1]&rdquo;</blockquote><figcaption><strong>$r->[0]</strong><span>Google review$tag</span></figcaption></figure>};
}

sub reviews_html {
  my ($start) = @_; $start //= 0;
  my $h = qq{<section class="section grey"><div class="container"><div class="section-head"><div><span class="eyebrow">Klantenbeoordelingen</span><h2>Wat klanten over Faster zeggen</h2></div><p>Echte Google-reviews, geen verzonnen teksten.</p></div><div class="review-grid">};
  $h .= review_card($REVIEWS[($start + $_) % @REVIEWS], '') for 0..5;
  $h . '</div></div></section>';
}

sub hero_html {
  my $p = shift;
  my $img = $p->{img} // 'faster-road-transport.jpg';
  my $alt = $p->{imgalt} // 'Sleepwagen van Faster met een auto op het plateau en een bestelbus aan de takel';
  my $h1b = $p->{h1b} ? qq{<br><span>$p->{h1b}</span>} : '';
  my @idx = ($p->{kind} // "") eq "city" ? map { (($p->{reviews} // 0) + $_) % @REVIEWS } 0..2 : 0..$#REVIEWS;
  my $slides = join "", map { review_card($REVIEWS[$idx[$_]], $_ == 0 ? " is-active" : "") } 0..$#idx;
  return <<"H";
<section class="hero"><div class="container hero-grid">
<div class="hero-copy"><span class="eyebrow">$p->{eyebrow}</span>
<h1>$p->{h1}$h1b</h1>
<p class="hero-sub">$p->{sub}</p>
<p class="hero-intro">$p->{intro}</p>
<div class="hero-actions"><a class="btn btn-call" href="{{PHONE_HREF}}">Bel direct: {{PHONE}}</a><a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp uw locatie</a></div>
<div class="proof">
<div><strong>&plusmn; 30 min*</strong><span>vaak snel ter plaatse</span></div>
<div><strong>vanaf &euro;{{PRICE}}</strong><span>vaste prijs vooraf</span></div>
<div><strong>24/7</strong><span>ook &rsquo;s nachts en in het weekend</span></div>
</div>
<div class="review-slider" aria-label="Google reviews">$slides</div>
</div>
<figure class="hero-media"><img src="{{R}}assets/img/$img" alt="$alt" width="1600" height="1200" loading="eager" fetchpriority="high"><figcaption>Eigen materieel &middot; echte opdrachten</figcaption></figure>
</div>
<div class="container"><p class="footnote">* Bij dringende oproepen vaak mogelijk, afhankelijk van uw locatie en het verkeer. U hoort bij het bellen hoe snel we er kunnen zijn.</p></div>
</section>
H
}

my $USPS = <<'H';
<section class="usp-band"><div class="container usp-grid">
<div><strong>Snel bij u</strong><span>Bij spoed vaak binnen 30 minuten ter plaatse.</span></div>
<div><strong>Scherpe vaste prijs</strong><span>Vanaf &euro;{{PRICE}}. U hoort de prijs vooraf, geen verrassingen.</span></div>
<div><strong>Geen abonnement</strong><span>Geen lidmaatschap of pechhulppas nodig. U betaalt per rit.</span></div>
<div><strong>U kiest de bestemming</strong><span>Uw garage, uw huis, de dealer of een schadebedrijf.</span></div>
</div></section>
H

my $STEPS = <<'H';
<section class="section"><div class="container"><div class="section-head"><div><span class="eyebrow">Zo werkt het</span><h2>In drie stappen geholpen</h2></div><p>Geen ingewikkelde procedure. Eén telefoontje of WhatsApp is genoeg.</p></div>
<ol class="steps">
<li><strong>Bel of WhatsApp</strong><span>Vertel waar de auto staat, wat er aan de hand is en waar hij naartoe moet. Deel uw locatie in WhatsApp, dan vinden we u meteen.</span></li>
<li><strong>Vaste prijs vooraf</strong><span>U hoort direct wat de rit kost. Pas als u akkoord bent, vertrekt de sleepwagen.</span></li>
<li><strong>Wij slepen, u rijdt mee</strong><span>De auto gaat veilig op het plateau en wordt vastgezet. Wij brengen hem naar het adres dat u kiest.</span></li>
</ol></div></section>
H

my $GALLERY = <<'H';
<section class="section white"><div class="container"><div class="section-head"><div><span class="eyebrow">Het echte werk</span><h2>Geen stockfoto&rsquo;s, eigen sleepwagens</h2></div><p>Dit is ons materieel en dit zijn echte opdrachten.</p></div>
<div class="gallery">
<figure class="g-large"><img src="{{R}}assets/img/faster-road-transport.jpg" alt="Gele sleepwagen van Faster met een auto op het plateau en een bestelbus aan de takel" width="1600" height="1200" loading="lazy"><figcaption>Twee voertuigen in één rit</figcaption></figure>
<figure><img src="{{R}}assets/img/faster-intervention-workshop.jpg" alt="Witte bestelbus wordt op het plateau van een sleepwagen van Faster getrokken" width="1288" height="966" loading="lazy"><figcaption>Bestelbus opladen</figcaption></figure>
<figure><img src="{{R}}assets/img/faster-warehouse.jpg" alt="Sleepwagen van Faster met een auto op het plateau in een loods" width="738" height="1156" loading="lazy"><figcaption>Veilig vastgezet</figcaption></figure>
</div></div></section>
H

my $SAFETY = <<'H';
<section class="section safety"><div class="container safety-grid">
<div><span class="eyebrow">Staat u stil langs de weg?</span><h2>Eerst veiligheid,<br>dan Faster.</h2><p>Pech is vervelend, maar hulp is onderweg. Let tot die tijd op uw eigen veiligheid en die van uw passagiers.</p>
<ol class="safety-list"><li>Zet de alarmlichten aan.</li><li>Trek een veiligheidshesje aan.</li><li>Stap uit aan de kant van de vangrail.</li><li>Wacht achter de vangrail, niet bij de auto.</li></ol>
<p class="safety-note">Staat de auto op de snelweg op een rijstrook? Bel eerst 112 of Rijkswaterstaat (0800-8002). <a href="{{R}}kennisbank/pech-op-de-snelweg/">Lees wat u moet doen bij pech op de snelweg</a>.</p></div>
<div class="quote-box"><strong>&ldquo;Voor elk probleem is een oplossing.&rdquo;</strong><p>Niet elke situatie is makkelijk, maar de duurste oplossing is niet altijd de beste. Wij kijken eerst wat er echt nodig is.</p><a class="btn btn-dark" href="{{PHONE_HREF}}">Bel {{PHONE}}</a></div>
</div></section>
H

my $CTA = <<'H';
<section class="cta-band"><div class="container cta-inner"><div><h2>Staat uw auto stil?</h2><p>Bel of stuur een WhatsApp met uw locatie. Dag en nacht, ook in het weekend.</p></div><div class="cta-actions"><a class="btn btn-dark" href="{{PHONE_HREF}}">Bel {{PHONE}}</a> <a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp</a></div></div></section>
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
<button class="btn btn-call" type="submit">Vraag een vaste prijs aan</button>
<p class="form-note">Spoed? Bel of WhatsApp ons, dat is sneller dan het formulier.</p>
</form>
H
}

sub svc_links {
  join " &middot; ", map { qq{<a href="{{R}}$_->{url}">$_->{label}</a>} } sort { ($a->{order} // 50) <=> ($b->{order} // 50) } grep { ($_->{kind} // "") eq "dienst" } values %P;
}

sub price_card {
  my $what = shift;
  qq{<div class="price-card"><span>$what</span><strong>vanaf &euro;{{PRICE}}</strong><p>Vaste prijs vooraf. Bij spoed vaak binnen 30 minuten ter plaatse.</p><a class="btn btn-dark" href="{{PHONE_HREF}}">Bel {{PHONE}}</a><a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp</a></div>};
}

# ---------------------------------------------------------------- templates
sub city_main {
  my $p = shift;
  my $n = $p->{label};
  my $near = '';
  if ($p->{near}) {
    my @l = map { my $q = $BYSLUG{"sleepdienst/$_"}; $q ? qq{<a href="{{R}}$q->{url}">Sleepdienst $q->{label}</a>} : do { warn "$p->{src}: near $_ unknown\n"; () } } split /\s*,\s*/, $p->{near};
    $near = '<div class="near"><strong>Ook in de buurt:</strong> ' . join('', @l) . qq{<a href="{{R}}sleepdienst/">Alle plaatsen &rarr;</a></div>} if @l;
  }
  my $pc = price_card("Sleepdienst $n");
  return <<"H";
{{HERO}}
<section class="section"><div class="container two-col"><div class="prose">
<h2>Sleepdienst $n: wegen en knelpunten</h2>$p->{roads}
<h2>Auto slepen in $n: goed om te weten</h2>$p->{local}
$near
<p class="svc-links"><strong>Wat wij doen in $n:</strong> {{SVCLINKS}}</p>
</div><aside class="side">$pc</aside></div></section>
H
}

sub city_faq {
  my $p = shift;
  my $n = $p->{label};
  return (
    ["Hoe snel is de sleepdienst in $n er?", "Bij spoed zijn we vaak binnen 30 minuten bij u, afhankelijk van waar u staat en het verkeer. Bij het bellen hoort u hoe snel we er kunnen zijn."],
    ["Wat kost een sleepdienst in $n?", "Een korte rit begint vanaf €$PRICE. De vaste prijs hangt af van de afstand, het voertuig en het tijdstip, en u hoort hem vooraf."],
    ["Heb ik een abonnement nodig?", "Nee. U betaalt per rit, zonder lidmaatschap of pechhulppas."],
    ["Waar brengen jullie mijn auto naartoe?", "Waar u wilt: uw eigen garage, uw huis, de dealer of een schadebedrijf."],
  );
}

sub page_main {
  my $p = shift;
  my $intro = $p->{lead} ? qq{<div class="lead">$p->{lead}</div>} : '';
  my $h1b = $p->{h1b} ? qq{ <span>$p->{h1b}</span>} : '';
  return <<"H";
<section class="page-head"><div class="container narrow"><h1>$p->{h1}$h1b</h1>$intro<div class="hero-actions"><a class="btn btn-call" href="{{PHONE_HREF}}">Bel {{PHONE}}</a><a class="btn btn-wa" href="{{WA_HREF}}">WhatsApp</a></div></div></section>
$p->{main}
H
}

# ---------------------------------------------------------------- layout
sub nav_html {
  my $p = shift;
  join '', map { my $cur = $p->{url} ne '' && index($p->{url}, $_->[1]) == 0 ? ' aria-current="page"' : ''; qq{<a href="{{R}}$_->[1]"$cur>$_->[0]</a>} } @NAV;
}

sub crumbs {
  my $p = shift;
  return ('', '') if $p->{url} eq '' || ($p->{crumbs} // '') eq 'none';
  my @c = (['Home', '']);
  push @c, map { [split /\|/] } split /\s*>\s*/, $p->{crumbs} if $p->{crumbs};
  push @c, [$p->{label}, $p->{url}];
  my $html = '<nav class="crumbs container" aria-label="Kruimelpad">' . join(' <span>/</span> ', map { $_ == $#c ? "<span>$c[$_][0]</span>" : qq{<a href="{{R}}$c[$_][1]">$c[$_][0]</a>} } 0..$#c) . '</nav>';
  my $i = 0;
  # Plain concatenation: qq{{...}} with nested braces swallowed the jstr() calls into the string (invalid JSON-LD until 2026-10-19).
  my $ld = '{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[' . join(',', map { $i++; '{"@type":"ListItem","position":' . $i . ',"name":"' . jstr($_->[0]) . '","item":"' . "$BASE/$_->[1]" . '"}' } @c) . ']}';
  return ($html, qq{<script type="application/ld+json">$ld</script>});
}

sub business_ld {
  my $p = shift;
  my $area = ($p->{kind} // '') eq 'city' ? '{"@type":"City","name":"' . jstr($p->{label}) . '"}' : '{"@type":"Country","name":"Nederland"}';
  return qq{<script type="application/ld+json">{"\@context":"https://schema.org","\@type":"AutomotiveBusiness","name":"$NAME","url":"$BASE/","telephone":"$PHONE","image":"$BASE/assets/img/faster-road-transport.jpg","priceRange":"vanaf €$PRICE","openingHours":"Mo-Su 00:00-23:59","areaServed":$area}</script>};
}

my $LOGO = '<a class="brand" href="{{R}}" aria-label="Sleepdienst Faster, naar de homepage"><img src="{{R}}assets/img/faster-truck.png" alt="" width="145" height="48"><span class="brand-text"><small>SLEEPDIENST</small><strong>FASTER</strong></span></a>';

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
  my $faq_ld = @faq ? '<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' . join(',', map { '{"@type":"Question","name":"' . jstr($_->[0]) . '","acceptedAnswer":{"@type":"Answer","text":"' . jstr($_->[1]) . '"}}' } @faq) . ']}</script>' : '';
  my $biz = ($p->{url} eq "" || $p->{url} eq "contact/") ? business_ld($p) : '';
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
<meta name="theme-color" content="#f6c400">
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
<div class="topbar"><div class="container topbar-inner"><span><b>24/7 bereikbaar</b> &middot; ook &rsquo;s nachts en in het weekend</span><span class="topbar-right">Vaste prijs vooraf &middot; vanaf &euro;{{PRICE}} &middot; geen abonnement</span></div></div>
<header class="site-header"><div class="container nav-wrap">
$LOGO
<nav class="main-nav" id="main-nav" aria-label="Hoofdmenu">$nav</nav>
<div class="nav-actions"><a class="btn btn-wa btn-small" href="{{WA_HREF}}">WhatsApp</a><a class="btn btn-call btn-small" href="{{PHONE_HREF}}">Bel 24/7</a><button class="menu-toggle" type="button" aria-controls="main-nav" aria-expanded="false">Menu</button></div>
</div></header>
$crumb_html
<main>
$main
</main>
<footer class="site-footer"><div class="container footer-grid">
<div>$LOGO
<p>Sleepdienst voor auto&rsquo;s en bestelbussen in heel Nederland. Dag en nacht bereikbaar, vaste prijs vooraf, geen abonnement.</p>
<p><a class="foot-call" href="{{PHONE_HREF}}">{{PHONE}}</a><a href="{{WA_HREF}}">WhatsApp</a></p></div>
<div><h3>Werkgebied</h3>$foot_cities<a href="{{R}}sleepdienst/">Alle plaatsen</a></div>
<div><h3>Diensten</h3>$foot_dien</div>
<div><h3>Informatie</h3>$foot_info</div>
</div><div class="container footer-bottom"><span>&copy; $year Sleepdienst Faster</span><span>Prijzen inclusief btw, tenzij anders vermeld.</span></div><div class="faster-network" style="max-width:1200px;margin:0 auto;padding:14px 20px;font-size:13px;line-height:1.6;opacity:.85;display:flex;flex-wrap:wrap;gap:4px 16px"><span>Faster in Europa:</span> <a href="https://takeldienst-depannage.com/" hreflang="nl-BE" style="color:inherit;text-decoration:underline">Belgi&euml; &ndash; Takeldienst</a> <a href="https://abschleppdienst-faster.de/" hreflang="de-DE" style="color:inherit;text-decoration:underline">Deutschland &ndash; Abschleppdienst</a> <a href="https://fasterbreakdownrecovery.co.uk/" hreflang="en-GB" style="color:inherit;text-decoration:underline">United Kingdom &ndash; Breakdown recovery</a></div></footer>
<div class="mobile-bar"><a href="{{PHONE_HREF}}">Bel nu</a><a class="wa" href="{{WA_HREF}}">WhatsApp</a></div>
<script src="{{R}}assets/js/main.js" defer></script>
</body>
</html>
H

  for (1..3) {
    $html =~ s/\{\{HERO\}\}/hero_html($p)/ge;
    $html =~ s/\{\{LIST:(\w+)\}\}/list_html($1)/ge;
    $html =~ s/\{\{REVIEWS\}\}/reviews_html($p->{reviews} \/\/ 0)/ge;
    $html =~ s/\{\{USPS\}\}/$USPS/g;
    $html =~ s/\{\{SVCLINKS\}\}/svc_links()/ge;
    $html =~ s/\{\{STEPS\}\}/$STEPS/g;
    $html =~ s/\{\{GALLERY\}\}/$GALLERY/g;
    $html =~ s/\{\{SAFETY\}\}/$SAFETY/g;
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
  $html = link_mentions($p, $html, $R);

  make_path(dirname($out)) if $out =~ m{/};
  open my $fh, '>:encoding(UTF-8)', $out or die "$out: $!";
  print $fh $html; close $fh;
  push @written, $out;
}

# Contextual links from words that are already in the text: the first unlinked mention of a place
# ("Breda") or guide topic ("pech op de snelweg") in a <p>/<li> of the page body becomes a link.
# The visible text never changes (checked). Skips targets the body already links (the "Ook in de
# buurt" block does not count) and list items that are already links. At most 3 per page,
# targets with the fewest such links go first.
my %MENTION_IN;
my %GUIDE_PHRASES;   # filled in BEGIN because the page loop above runs before this point
BEGIN { %GUIDE_PHRASES = (
  'kennisbank/pech-op-de-snelweg/'           => ['pech op de snelweg', 'pech langs de snelweg'],
  'kennisbank/sleepdienst-zonder-abonnement/' => ['zonder abonnement', 'geen abonnement'],
  'kennisbank/wat-kost-een-sleepdienst/'     => ['wat een sleepdienst kost', 'kosten van een sleepdienst'],
  'kennisbank/verkeerd-getankt/'             => ['verkeerd getankt'],
  'kennisbank/accu-leeg/'                    => ['accu leeg', 'lege accu'],
  'kennisbank/na-een-aanrijding/'            => ['na een aanrijding'],
) }
sub link_mentions {
  my ($p, $html, $R) = @_;
  my ($pre, $main, $post) = $html =~ m{^(.*?<main\b[^>]*>)(.*)(</main>.*)$}s or return $html;
  my $plain = sub { (my $s = shift) =~ s/<[^>]+>//g; $s };
  my $before = $plain->($main);
  (my $body = $main) =~ s{<div class="near">.*?</div>}{}s;
  # set aside what must never get a link: card links that contain paragraphs (no nested <a>),
  # reviews, and paragraphs that quote a customer
  my @keep;
  $main =~ s{(<a\b[^>]*>(?:(?!</a>).)*?<(?:p|li|h3)\b.*?</a>|<figure\b.*?</figure>|<blockquote\b.*?</blockquote>|<p\b[^>]*>[^<]*&ldquo;.*?</p>)}{push @keep, $1; "\x00" . $#keep . "\x00"}gse;
  my %linked = map { $_ => 1 } $body =~ /href="\Q$R\E([^"#?]*)"/g;
  my @t;
  for my $q (values %P) {
    next if $q->{url} eq $p->{url} || $linked{$q->{url}};
    my @ph = ($q->{kind} // '') eq 'city' ? (split /\s+en\s+/, $q->{label}) : @{ $GUIDE_PHRASES{$q->{url}} // [] };
    push @t, [$q, \@ph] if @ph;
  }
  @t = sort { ($MENTION_IN{$a->[0]{url}} // 0) <=> ($MENTION_IN{$b->[0]{url}} // 0) || $a->[0]{url} cmp $b->[0]{url} } @t;
  my $n = 0;
  for my $t (@t) {
    last if $n >= 3;
    my ($q, $ph) = @$t;
    my $done = 0;
    for my $name (@$ph) {
      last if $done;
      $main =~ s{(<(p|li)\b[^>]*>)(.*?)(</\2>)}{
        my ($o, $tag, $in, $e) = ($1, $2, $3, $4);
        unless ($done || ($tag eq 'li' && $in =~ /<a\b/)) {
          my @parts = split /(<[^>]+>)/, $in; my $ina = 0;
          for my $x (@parts) {
            if ($x =~ /^</) { $ina++ if $x =~ /^<a\b/i; $ina-- if $x =~ m{^</a>}i; next }
            next if $ina || $done;
            $done = 1 if $x =~ s{(?<![\w\-])(\Q$name\E)(?![\w\-])(?!\s*(?:weg|straat|laan|dijk|baan)\b)}{<a href="$R$q->{url}">$1</a>}i;
          }
          $in = join '', @parts;
        }
        "$o$in$e" }gse;
    }
    if ($done) { $n++; $MENTION_IN{$q->{url}}++ }
  }
  $main =~ s/\x00(\d+)\x00/$keep[$1]/g;
  die "$p->{src}: link_mentions changed the visible text\n" unless $plain->($main) eq $before;
  return $pre . $main . $post;
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

# ---------------------------------------------------------------- checks
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
  my ($t) = $h =~ m{<title>(.*?)</title>};
  printf "LONG TITLE (%d) %s: %s\n", length $t, $out, $t if length($t) > 65;
  print "H1 COUNT in $out\n" if (() = $h =~ /<h1/g) != 1;
}
printf "%d pages, %d broken links%s\n", scalar @written, $bad, $PREVIEW ? ' (PREVIEW: noindex on)' : '';
