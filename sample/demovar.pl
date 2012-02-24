#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<demo:setvar name="hoge" value="HOGE"/>
<div>
 <var></var> = <em><demo:getvar name="hoge"></demo:getvar></em>
</div>
<demo:setarray name="location">
  <demo:li>Jan Mayen</demo:li>
  <demo:li>Bodo</demo:li>
  <demo:li>Trondheim</demo:li>
  <demo:li>Bergen</demo:li>
</demo:setarray>
<ol>
 <li></li>
</ol>
END_XHTML

my $logic = <<'END_LOGIC';
my %var;
my $array_name;
for ('demo:setvar') {
    my($attr) = @{$_};
    my $name = $attr->{'name'};
    my $value = $attr->{'value'};
    $var{$name} = $value;
}
for ('var') {
    stag;
    print 'hoge';
    etag;
}
for ('demo:getvar') {
    my($attr) = @{$_};
    my $name = $attr->{'name'};
    print $var{$name} || q();
}
for ('demo:setarray') {
    my($attr) = @{$_};
    $array_name = $attr->{'name'};
    $var{$array_name} = [];
    content;
    $array_name = undef;
}
for ('demo:li') {
    my($attr, $data) = @{$_};
    push @{$var{$array_name}}, $data;
}
for ('li') {
    for my $x (@{$var{'location'}}) {
        stag;
        print $x;
        etag;
    }
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->();

__END__
<div>
 <var>hoge</var> = <em>HOGE</em>
</div>
<ol>
 <li>Jan Mayen</li>
 <li>Bodo</li>
 <li>Trondheim</li>
 <li>Bergen</li>
</ol>

