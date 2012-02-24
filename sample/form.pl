#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<html>
 <body>
  <form id="form1">
   <select name="f0">
    <option></option>
   </select>
   <input type="text" name="f1" />
   <textarea name="f2"></textarea>
   <select name="f3">
    <option value="f3a">F3A</option>
    <option value="f3b">F3B</option>
    <option value="f3c">F3C</option>
   </select>
   <div id="f4g">
   <input type="checkbox" name="f4" /><span id="f4v">&nbsp;</span>,
   </div>
   <input type="radio" name="f5" value="a" />A,
   <input type="radio" name="f5" value="b" />B,
   <input type="radio" name="f5" value="c" />C,
  </form>
 </body>
</html>
END_XHTML

my $logic = <<'END_LOGIC';
my($value, $label);
for ('#form1') {
    stag method => 'post', action => 'hoge';
    content;
    etag;
}
for ('select[name="f0"] option') {
    my $sel = 'f0c';
    for my $v (qw(f0a f0b f0c f0d)) {
        my @selected = $sel eq $v ? (selected => 'selected') : ();
        stag value => $v, @selected;
        print uc $v;
        etag;
    }
}
for ('input[name="f1"]') {
    stag value => 'hoge <&nbsp;">';
}
for ('textarea[name="f2"]') {
    stag;
    print 'fuga <&nbsp;">';
    etag;
}
for ('select[name="f3"] option[value="f3b"]') {
    stag selected => 'selected';
    content;
    etag;
}
for ('#f4g') {
    for my $v (qw(foo bar baz)) {
        ($value, $label) = ($v, uc $v);
        content;
    }
}
for ('input[name="f4"]') {
    stag value => $value;
}
for ('#f4v') {
    print $label;
}
for ('input[name="f5"]') {
    my($attr) = @{$_};
    my @checked = $attr->{'value'} eq 'a' ? ('checked' => 'checked') : ();
    stag @checked;
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->();

__END__
<html>
 <body>
  <form action="hoge" method="post">
   <select name="f0">
    <option value="f0a">F0A</option>
    <option value="f0b">F0B</option>
    <option value="f0c" selected="selected">F0C</option>
    <option value="f0d">F0D</option>
   </select>
   <input type="text" name="f1" value="hoge &lt;&amp;nbsp;&quot;&gt;" />
   <textarea name="f2">fuga &lt;&amp;nbsp;&quot;&gt;</textarea>
   <select name="f3">
    <option value="f3a">F3A</option>
    <option value="f3b" selected="selected">F3B</option>
    <option value="f3c">F3C</option>
   </select>
   <input type="checkbox" name="f4" value="foo" />FOO,
   <input type="checkbox" name="f4" value="bar" />BAR,
   <input type="checkbox" name="f4" value="baz" />BAZ,
   <input type="radio" name="f5" value="a" checked="checked" />A,
   <input type="radio" name="f5" value="b" />B,
   <input type="radio" name="f5" value="c" />C,
  </form>
 </body>
</html>

