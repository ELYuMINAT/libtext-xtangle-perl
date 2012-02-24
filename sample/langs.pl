#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<h1></h1>
<ul>
 <li id="langs"><a href=""></a></li>
</ul>
END_XHTML

my $logic = <<'END_LOGIC';
my @langs = @_;
my $entry;
for ('h1') {
    stag id => 'lightlangs';
    print 'Example of Lightweight languages';
    etag;
}
for ('li#langs') {
    while (@{$entry}{qw(name link)} = splice @langs, 0, 2) {
        element;
    }
}
for ('li@langs a') {
    stag href => $entry->{'link'};
    print $entry->{'name'};
    etag;
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->(
    'Python' => 'http://www.python.org/',
    'Ruby' => 'http://www.ruby-lang.org/',
    'Perl' => 'http://www.perl.org/',
);

__END__
<h1 id="lightlangs">Example of Lightweight languages</h1>
<ul>
 <li><a href="http://www.python.org/">Python</a></li>
 <li><a href="http://www.ruby-lang.org/">Ruby</a></li>
 <li><a href="http://www.perl.org/">Perl</a></li>
</ul>

