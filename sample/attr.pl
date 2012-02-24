#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<html>
 <body>
  <h1><a id="a1" href="replaced">replacing attributes</a></h1>
  <p><a id="a2" href="http://example.net/">examples</a></p>
  <p><a id="a3" href="http://d.hatena.ne.jp/$1/$2">id:$1:$2</a></p>
 </body>
</html>
END_XHTML

my $logic = <<'END_LOGIC';
for ('#a1') {
    stag href => 'http://hoge.gr.jp/';
    content;
    etag;
}
for ('#a2') {
    my($attr, $data) = @{$_};
    stag href => $attr->{'href'} . 'ja/';
    print $data . ' (Japanese)';
    etag;
}
for ('#a3') {
    my($attr, $data) = @{$_};
    my @path = ('someone', 132424);
    stag href => expand($attr->{'href'}, @path);
    print expand($data, @path);
    etag;
}
END_LOGIC

sub expand {
    my($text, @arg) = @_;
    $text =~ s{\$([1-9][[:digit:]]?)}{
        defined $arg[$1 - 1] ? $arg[$1 - 1] : q()
    }msxge;
    return $text;
}

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->();

__END__
<html>
 <body>
  <h1><a href="http://hoge.gr.jp/">replacing attributes</a></h1>
  <p><a href="http://example.net/ja/">examples (Japanese)</a></p>
  <p><a href="http://d.hatena.ne.jp/someone/132424">id:someone:132424</a></p>
 </body>
</html>
