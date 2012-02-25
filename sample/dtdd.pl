#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<dl>
 <dt></dt>
 <dd></dd>
</dl>
END_XHTML

my $logic = <<'END_LOGIC';
my @symbol = @_;
my($t, $d);
for ('dl') {
    stag;
    while (($t, $d) = splice @symbol, 0, 2) {
        content;
    }
    etag;
}
for ('dt') {
    stag;
    print $t;
    etag;
}
for ('dd') {
    stag;
    print $d;
    etag;
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->(qw(dollar scalar atmark array percent hash));

__END__
<dl>
 <dt>dollar</dt>
 <dd>scalar</dd>
 <dt>atmark</dt>
 <dd>array</dd>
 <dt>percent</dt>
 <dd>hash</dd>
</dl>

