#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<span id="set_hoge">HOGE HOGE</span>
<ul>
 <li><span id="get_hoge"></span></li>
</ul>
END_XHTML

my $logic = <<'END_LOGIC';
my @list = @_;
my $hoge;
my $i;
for ('#set_hoge') {
    my($attr, $data) = @{$_};
    $hoge = $data;
}
for ('#get_hoge') {
    print $hoge . q( ) . $i;
}
for ('li') {
    for (@list) {
        $i = $_;
        element;
    }
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->(3 .. 6);

__END__
<ul>
 <li>HOGE HOGE 3</li>
 <li>HOGE HOGE 4</li>
 <li>HOGE HOGE 5</li>
 <li>HOGE HOGE 6</li>
</ul>
