#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<html>
 <body>
  <h1>conditional</h1>
  <div id="cond">
  <h2 id="title"></h2>
  <p id="zero">no data.</p>
  <p id="one">one: <span>data</span>.</p>
  <ul id="many">
   <li></li>
  </ul>
  </div>
 </body>
</html>
END_XHTML

my $logic = <<'END_LOGIC';
my($param) = @_;
my $cond;
for ('#cond') {
    for my $c (@{$param}) {
        $cond = $c;
        content;
    }
}
for ('#title') {
    stag;
    print $cond->{'title'};
    etag;
}
for ('#zero') {
    if (exists $cond->{'zero'}) {
        element;
    }
}
for ('#one') {
    if (exists $cond->{'one'}) {
        element;
    }
}
for ('#one span') {
    print $cond->{'one'};
}
for ('#many') {
    if (exists $cond->{'many'}) {
        element;
    }
}
for ('#many li') {
    for my $x (@{$cond->{'many'}}) {
        stag;
        print $x;
        etag;
    }
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->([
    {'title' => 'three', 'many' => [qw(1 2 3)]},
    {'title' => 'zero', 'zero' => 0},
    {'title' => 'one', 'one' => 1},
]);

__END__
<html>
 <body>
  <h1>conditional</h1>
  <h2>three</h2>
  <ul>
   <li>1</li>
   <li>2</li>
   <li>3</li>
  </ul>
  <h2>zero</h2>
  <p>no data.</p>
  <h2>one</h2>
  <p>one: 1.</p>
 </body>
</html>
