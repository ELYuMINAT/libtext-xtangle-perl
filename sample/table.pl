#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<table>
 <caption></caption>
 <tr>
  <td></td>
 </tr>
</table>
END_XHTML

my $logic = <<'END_LOGIC';
my @rows = @_;
my $row;
for ('caption') {
    stag;
    print 'ABC';
    etag;
}
for ('tr') {
    for (@rows) {
        $row = $_;
        element;
    }
}
for ('td') {
    my($attr, @col) = @{$row};
    for my $c (@col) {
        stag %{$attr};
        print $c;
        etag;
    }
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->(
    [{'width' => '32', 'align' => 'left'}, 'L1', 'L2'],
    [{'align' => 'center', 'colspan' => 2}, 'C1'],
    [{'align' => 'right'}, 'R1', 'R2'],
);

__END__
<table>
 <caption align="left">ABC</caption>
 <tr>
  <td width="32" align="left">L1</td>
  <td width="32" align="left">L2</td>
 </tr>
 <tr>
  <td align="center" colspan="2">C1</td>
 </tr>
 <tr>
  <td align="right">R1</td>
  <td align="right">R2</td>
 </tr>
</table>

