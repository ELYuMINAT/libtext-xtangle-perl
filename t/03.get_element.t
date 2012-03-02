use strict;
use warnings;
use Test::Base;
use Text::Xtangle;

plan tests => 6;

{
    my $class = 'Text::Xtangle';
    
    ok eval{ $class->can('get_element') }, 'can get_element';
    ok eval{ $class->can('fold_element') }, 'can fold_element';

    my $xhtml = <<'END_XHTML';
<!DOCTYPE html>
<html>
<head>
 <meta charste="UTF-8" />
 <title>test</title>
</head>
<body>
<div id="mark:test">
<form action="/test.cgi" method="POST">
<input type="hidden" name="foo" value="FOO" />
<input type="text" name="bar" value="" />
<input type="submit" value=" TEST ME " />
</form>
</div>
</body>
</html>
END_XHTML
    my $doc = $class->document($xhtml);
    my $form = $class->get_element($doc, '#mark:test form');
    is_deeply $form->[0],
        [q(), q(<), 'form', [
            q( ), 'action', q(="), '/test.cgi', q("),
            q( ), 'method', q(="), 'POST', q("),
        ], q(), q(>), "\n"], 'get_element mark:test form';

    my $bar = $class->get_element($form, 'input[name="bar"]');
    is_deeply $bar->[0],
        [q(), q(<), 'input', [
            q( ), 'type', q(="), 'text', q("),
            q( ), 'name', q(="), 'bar', q("),
            q( ), 'value', q(="), q(), q("),
        ], q( ), q(/>), "\n"], 'get_element input[name="bar"]';
    $class->_attr($bar->[0], 'value' => 'BAR');
    is_deeply $bar->[0],
        [q(), q(<), 'input', [
            q( ), 'type', q(="), 'text', q("),
            q( ), 'name', q(="), 'bar', q("),
            q( ), 'value', q(="), q(BAR), q("),
        ], q( ), q(/>), "\n"], 'attr change bar => BAR';
    my $got_form = $class->fold_element($form);
    my $expected_form = <<'END_XHTML';
<form action="/test.cgi" method="POST">
<input type="hidden" name="foo" value="FOO" />
<input type="text" name="bar" value="BAR" />
<input type="submit" value=" TEST ME " />
</form>
END_XHTML
    is $got_form, $expected_form, 'fold_element form';
}

