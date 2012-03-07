use strict;
use warnings;
use Test::Base tests => 6;

BEGIN { use_ok('Text::Xtangle') };

can_ok('Text::Xtangle', 'zip');

my $xhtml = <<'END_XHTML';
<h1></h1>
END_XHTML

my $logic = <<'END_LOGIC';
for ('h1') {
    stag;
    print 'Hello, World';
    etag;
}
END_LOGIC

my $src = Text::Xtangle->zip($xhtml, $logic);

ok ! ref $src, 'isa Str';

my $code = eval $src;
$@ and diag "$@";
ok ! $@, 'enable to eval';
is 'CODE', ref $code, 'isa CodeRef';
is "<h1>Hello, World</h1>\n", $code->(), 'run it';

