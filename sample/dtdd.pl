#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

# tricky markup of definition lists to pass the W3C validator.
# <!ELEMENT dl (dt|dd)+>
my $xhtml = <<'END_XHTML';
<dl>
<dd id="ditem">
<dl>
 <dt></dt>
 <dd></dd>
</dl>
</dd>
</dl>
END_XHTML

my $logic = <<'END_LOGIC';
my @symbol = @_;
my($t, $d);
for ('#ditem') {
    content;
}
for ('#ditem dl') {
    while (($t, $d) = splice @symbol, 0, 2) {
        content;
    }
}
for ('#ditem dt') {
    stag;
    print $t;
    etag;
}
for ('#ditem dd') {
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

