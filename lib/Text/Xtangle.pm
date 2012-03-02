package Text::Xtangle;
use strict;
use warnings;
use Carp;

our $VERSION = '0.007';
# $Id$

## no critic qw(ComplexRegexes EscapedMetacharacters EnumeratedClasses)

my %XML_SPECIAL = (
    q(&) => '&amp;', q(<) => '&lt;', q(>) => '&gt;',
    q(") => '&quot;', q(') => q(&#39;), q(\\) => q(&#92;),
); 
my $ID = qr{[[:alpha:]_:][[:alnum:]_:-]*}msx;
my $SP = q([ \\t\\n\\r]);
my $NL = qr{(?:\r\n?|\n)}msx;
my $ATTR = qr{($SP+)($ID)($SP*=$SP*\")([^<>\"]*)(\")}msx;

sub zip {
    my($class, $xml, $script) = @_;
    ## no critic qw(ProhibitInterpolationOfLiterals)
    $class = ref $class || $class;
    my $doc = ref $xml ? $xml : $class->document($xml);
    my $logic = $class->logic($script);
    my $header = delete $logic->{'##init'};
    if ($header) {
        $header .= "\n";
    }
    my $idonly = delete $logic->{'##idonly'};
    my $perl = "my \$tmpl = sub{\n"
        . "use utf8;\n"
        . $header
        . "my \$_t=q();\n";
    my @path;
    my @todo = ($doc, 0);
    my @cont;
    while (@todo) {
        my $i = pop @todo;
        my $node = pop @todo;
        while ($i < @{$node->[1]}) {
            my $child = $node->[1][$i++];
            if (! ref $child) {
                $perl .= "\$_t.=" . quote($child) . ";\n";
                next;
            }
            if ($child->[0][1] ne q(<)) {
                $perl .= "\$_t.=" . quote(@{$child->[0]}[0, 4, 6]) . ";\n";
                next;
            }
            my $key = $class->_find_logic($idonly, $logic, @path, $child->[0]);
            if (! $key) {
                my $a = $child->[0];
                my $stag = quote(@{$a}[0 .. 2], @{$a->[3]}, @{$a}[4 .. 6]);
                $perl .= "\$_t.=$stag;\n";
                next if $child->[0][5] eq q(/>);
                push @path, $child->[0];
                push @cont, quote(@{$child->[2]}[0 .. 2, 4 .. 6]), 'etag';
                push @todo, $node, $i;
                ($node, $i) = ($child, 0);
                next;
            }
            my $block = $class->_build_block($child, $logic->{$key}[0]);
            if ($block =~ m/^[ ]+content;\n/msx) {
                push @path, $child->[0];
                push @cont, $perl, $block, 'endblock';
                push @todo, $node, $i;
                ($node, $i, $perl) = ($child, 0, q());
                next;
            }
            $perl .= $block;
        }
        if (@cont) {
            my $op = pop @cont;
            if ($op eq 'etag') {
                my $etag = pop @cont;
                $perl .= "\$_t.=$etag;\n";
            }
            elsif ($op eq 'endblock') {
                my $childperl = $perl;
                my $block = pop @cont;
                $perl = pop @cont;
                $block =~ s{^[ ]+content;\n}{$childperl}gmosx;
                $perl .= $block;
            }
            pop @path;
        }
    }
    return $perl
        . "return \$_t;\n"
        . "};\n";
}

sub _build_block {
    my($class, $child, $tmpl) = @_;
    ## no critic qw(ProhibitInterpolationOfLiterals)
    my $stag = join q(,),
        (map { quote($_) } @{$child->[0]}[0, 1, 2]),
        q([) . (join q(,), map { quote($_) } @{$child->[0][3]}) . q(]),
        (map { quote($_) } @{$child->[0]}[4, 5, 6]);
    my $attr = join q(,), map { quote($_) } $class->_attr($child->[0]);
    my $data = quote($class->_data($child) || q());
    my $etag = quote(@{$child->[2]}[0 .. 2, 4 .. 6]);
    my $filter = $class->_choose_filter(
        $class->_data($child) || q(),
        $child->[0][2] eq 'textarea' ? 'xml' : 'text',
    );
    $tmpl =~ s/^[ ]+element;\n/ stag;\n content;\n etag;\n/gmsx;
    my $block = <<"EOS";
for ([{$attr}, $data]) {
$tmpl
}
EOS
    $block =~ s{^[ ]+stag(?:\s+(.+?))?;\n}{
        my $a = defined $1 ? $1 : q();
        "\$_t.=$class->stag([$stag], \x7b$a\x7d);\n"
    }egmsx;
    if ($child->[0][5] eq q(>)) {
        $block =~ s{
            ^[ ]+print\s+(.+?);\n
        }{\$_t.=$class->$filter(join q(), $1);\n}gmsx;
        $block =~ s{^[ ]+etag;\n}{\$_t.=$etag;\n}gmsx;
    }
    else {
        $block =~ s{^[ ]+content;\n}{}gmsx;
        $block =~ s{^[ ]+print\s+(.+?);\n}{}gmsx;
        $block =~ s{^[ ]+etag;\n}{}gmsx;
    }
    return $block;
}

sub get_element {
    my($class, $doc, $selector) = @_;
    my $selist = $class->_precompile_selector($selector);
    my @path;
    my @todo = ($doc, 0);
    my @cont;
    while (@todo) {
        my $i = pop @todo;
        my $node = pop @todo;
        while ($i < @{$node->[1]}) {
            my $child = $node->[1][$i++];
            next if ! ref $child || $child->[0][1] ne q(<);
            if ($class->_match_selector($selist, @path, $child->[0])) {
                return $child;
            }
            next if $child->[0][5] eq q(/>);
            push @path, $child->[0];
            push @cont, 'etag';
            push @todo, $node, $i;
            ($node, $i) = ($child, 0);
        }
        if (@cont) {
            pop @cont;
            pop @path;
        }
    }
    return;
}

sub fold_element {
    my($class, $element) = @_;
    my $src = $class->zip([[], [$element]], q());
    my $code = eval $src or croak "$@";
    return $code->();
}

sub document {
    my($class, $xml) = @_;
    my $document = [[], []];
    my @ancestor;
    my $node = $document;
    while($xml !~ m{\G\z}gcmosx) {
        my $t = $xml =~ m{\G(^[\x20\t]*)}gcmosx ? $1 : q();
        if ($xml =~ m{
            \G<
            (?: (?: ($ID) (.*?) ($SP*) (/?>)
                |   /($ID) ($SP*) >
                |   (\?.*?\?|\!(?:--.*?--|\[CDATA\[.*?\]\]|DOCTYPE[^>]+?))>
                )
                ($NL*)
            )?
        }gcmosx) {
            my($id1, $t2, $sp3, $gt4, $id5, $sp6, $t7, $nl8)
                = ($1, $2, $3, $4, $5, $6, $7, $8);
            if ($id1) {
                my $attr = [$t2 =~ m{$ATTR}msxog];
                my $element = [
                    [$t, q(<), $id1, $attr, $sp3, $gt4, $nl8], [],
                ];
                push @{$node->[1]}, $element;
                next if $gt4 eq q(/>);
                push @ancestor, $node;
                $node = $element;
                next;
            }
            elsif ($id5) {
                my $id1 = $node->[0][2];
                $id5 eq $id1 or croak "<$id1> ne </$id5>";
                $node->[2] = [$t, q(</), $id5, [], $sp6, q(>), $nl8];
                $node = pop @ancestor;
                next;
            }
            elsif ($t7) {
                push @{$node->[1]}, [
                    [$t, q(), q(), [], "<$t7>", q(), $nl8], [],
                ];
                next;
            }
            else {
                $t .= q(<);
            }
        }
        $t .= $xml =~ m{\G([^<\r\n]+$NL*|$NL+)}gcmosx ? $1 : q();
        if (@{$node->[1]} == 0 || ref $node->[1][-1]) {
            push @{$node->[1]}, $t;
        }
        else {
            $node->[1][-1] .= $t;
        }
    }
    @ancestor == 0 or croak 'is not formal XML.';
    return $document;
}

sub logic {
    my($class, $source) = @_;
    if ($source =~ m/\$_t/msx) {
        croak 'bad logic script source.';
    }
    my %logics;
    $logics{'##init'} = q();
    if ($source =~ m{\A(?!for)(.+?)\n^for}msx) {
        $logics{'##init'} = $1;
    }
    my $idonly = 1;
    while ($source =~ m{
        ^for[ ][(]'(.*?)'[)][ ]+[\{][^\n]*\n
        (.*?)
        ^[\}][^\n]*\n
    }gmosx) {
        my($selector, $statements) = ($1, $2);
        if ($selector !~ m/\A[\#]$ID\z/msx) {
            $idonly = 0;
        }
        my $selist = $class->_precompile_selector($selector);
        $logics{$selector} = [$statements, $selist];
    }
    $logics{'##idonly'} = $idonly;
    return \%logics;
}

sub _precompile_selector {
    my($class, $selector) = @_;
    my @compiled;
    for my $seterm (split /\s+/msx, $selector) {
        if ($seterm =~ m{\A
            ($ID)(?:\#($ID)|[.]([[:alnum:]_:-]+)|\[($ID)([~^\$*|]?=)"([^"]+)"\])?
        |   [*]? (?:\#($ID)|[.]([[:alnum:]_:-]+)|\[($ID)([~^\$*|]?=)"([^"]+)"\])
        \z}mosx) {
            my($tagname, $id, $classname) = ($1, $2 || $7, $3 || $8);
            my($attr, $op, $str) = $id ? ('id', q(=), $id)
                : $classname ? ('class', q(~=), $classname)
                : ($4 || $9, $5 || $10, $6 || $11);
            push @compiled, [$tagname, $attr, $op, $str];
        }
    }
    return \@compiled;
}

sub quote {
    my $s = join q(), grep { defined } @_;
    $s =~ s/([\\'])/\\$1/gmosx;
    return qq('$s');
}

sub _find_logic {
    my($class, $idonly, $logic, @path) = @_;
    my $stag = $path[-1];
    if (@{$stag->[3]} && $stag->[3][1] eq 'id') {
        my $tagname = $stag->[2];
        my $id = $stag->[3][3];
        my $se1 = q(#) . $id;
        my $se2 = $tagname . q(#) . $id;
        return $se1 if exists $logic->{$se1};
        return $se2 if exists $logic->{$se2};
        return if $idonly;
    }
    elsif ($idonly) {
        return;
    }
    for my $k (keys %{$logic}) {
        if ($class->_match_selector($logic->{$k}[1], @path)) {
            return $k;
        }
    }
    return;
}

sub _match_selector {
    my($class, $selector, @path) = @_;
    my @selist = @{$selector};
    return if ! $class->_match_selector_term(pop @selist, pop @path);
    my $seterm = shift @selist or return 1;
    for my $stag (@path) {
        next if ! $class->_match_selector_term($seterm, $stag);
        $seterm = shift @selist or return 1;
    }
    return;
}

sub _match_selector_term {
    my($class, $seterm, $stag) = @_;
    my $element_name = $stag->[2];
    my($tagname, $attr, $op, $str) = @{$seterm};
    return (! $tagname || $element_name eq $tagname)
        && (! $attr || $class->_attr_match($stag, $attr, $op, $str));
}

# see http://www.w3.org/TR/css-2010/#selectors
sub _attr_match {
    my($class, $stag, $attr, $op, $str) = @_;
    my $value = $class->_attr($stag, $attr);
    $value = defined $value ? $value : q();
    if ($op eq q(=)) {
        return $value eq $str;
    }
    if ($op eq q(~=)) {
        return 0 <= index " $value ", " $str ";
    }
    if ($op eq q(^=)) {
        return $str eq (substr $value, 0, length $str);
    }
    if ($op eq qq(\x24=)) {
        my($vsize, $psize) = ((length $value), (length $str));
        return $vsize >= $psize
            && $str eq (substr $value, $vsize - $psize, $psize);
    }
    if ($op eq q(*=)) {
        return 0 <= index $value, $str;
    }
    if ($op eq q(|=)) {
        return 0 <= index "-$value-", "-$str-";
    }
    return $value eq $str;
}

sub _data {
    my($class, $node) = @_;
    if ($node->[0][1] eq q(<)) {
        return exists $node->[1] && ! ref $node->[1][0] ? $node->[1][0] : q();
    }
    else {
        return join q(), @{$node->[0]}[0, 4, 6];
    }
}

sub stag {
    my($class, $tmpl, $attr) = @_;
    my $stag = [@{$tmpl}[0 .. 2], [@{$tmpl->[3]}], @{$tmpl}[4 .. 6]];
    $class->_attr($stag, 'id' => undef);
    while (my($k, $v) = each %{$attr}) {
        next if $k !~ /\A$ID\z/msx;
        $class->_attr($stag, $k => $class->_attr_filter($tmpl, $k, $v));
    }
    return join q(), @{$stag}[0 .. 2], @{$stag->[3]}, @{$stag}[4 .. 6];
}

sub _attr {
    my($class, $stag, @arg) = @_;
    my $attr = $stag->[3]; # [(' ', 'name', '="', 'value', '"') ...]
    if (! @arg) {
        my @indecs = map { $_ * 5 } 0 .. -1 + int @{$attr} / 5;
        return map { @{$attr}[$_ + 1, $_ + 3] } @indecs;
    }
    my $name = shift @arg or return;
    my $i = 0;
    while ($i < @{$attr}) {
        if ($attr->[$i + 1] eq $name) {
            return $attr->[$i + 3] if ! @arg;
            if (@arg == 1 && ! defined $arg[0]) {
                my @got = splice @{$attr}, $i, 5;
                return $got[3];
            }
            elsif (@arg) {
                $attr->[$i + 3] = $arg[0];
            }
            return $attr->[$i + 3];
        }
        $i += 5;
    }
    if (@arg && defined $arg[0]) {
        my @got = @{$attr} ? @{$attr}[-5 .. -1]
            : (q( ), q(), q(="), q(), q("));
        $got[1] = $name;
        $got[3] = $arg[0];
        push @{$attr}, @got;
        return $got[3];
    }
    return;
}

my %FILTERS = (
    'URI' => 'uri',
    'URL' => 'uri',
    'HTML' => 'xml',
    'XML' => 'xml',
    'RAW' => 'raw',
    'TEXT' => 'text',
);

sub _choose_filter {
    my($class, $modifier, $default_filter) = @_;
    my $filter = $FILTERS{$modifier} || $default_filter;
    return "escape_${filter}";
}

sub _attr_filter {
    my($class, $stag, $attrname, $value) = @_;
    return $value if ! defined $value;
    my $tagname = lc $stag->[2];
    my $filter = $class->_choose_filter(
        $class->_attr($stag, $attrname) || q(),
        $tagname eq 'input' && $attrname eq 'value' ? 'xml'
        : $attrname =~ /(?:\A(?:action|src|href|cite)|resource)\z/imsx ? 'uri'
        : 'text',
    );
    return $class->$filter($value);
}

sub escape_raw { return $_[1] }

sub escape_xml {
    my($class, $t) = @_;
    $t = defined $t ? $t : q();
    $t =~ s{([<>"'&\\])}{ $XML_SPECIAL{$1} }egmsx;
    return $t;
}

sub escape_text {
    my($class, $t) = @_;
    $t = defined $t ? $t : q();
    $t =~ s{
        (?:([<>"'\\])
        |\& (?: ([[:alpha:]_][[:alnum:]_]*
                |\#(?:[[:digit:]]{1,5}|x[[:xdigit:]]{2,4})
                );
            )?
        )
    }{
        $1 ? $XML_SPECIAL{$1} : $2 ? qq(\&$2;) : q(&amp;)
    }egmosx;
    return $t;
};

sub escape_uri {
    my($class, $t) = @_;
    $t = defined $t ? $t : q();
    if (utf8::is_utf8($t)) {
        require Encode;
        $t = Encode::encode('utf-8', $t);
    }
    $t =~ s{
        (%([[:xdigit:]]{2})?)|(&(?:amp;)?)|([^[:alnum:]\-_~*+=/.!,;:\@?\#])
    }{
        $2 ? $1 : $1 ? q(%25) : $3 ? q(&amp;) : sprintf '%%%02X', ord $4
    }egmosx;
    return $t;
}

1;

__END__

=pod

=head1 NAME

Text::Xtangle - Template system from a XML with a Presentation Logic Script.

=head1 VERSION

0.007

=head1 SYNOPSIS

    use Text::Xtangle;
    use Encode;
    
    # idonly-mode: fast! all prepared elements start id attribute.
    my $xhtml = <<'END_XHTML';
    <div id="mark:hentry" class="hentry">
     <h2 id="mark:h2"></h2>
     <div id="mark:entry-body" class="entry-body">RAW</div>
     <div id="mark:entry-date" class="entry-date">%Y-%m-%d %H:%M</div>
    </div>
    END_XHTML
    # idonly-mode: use '#ID' style
    my $logic = <<'END_LOGIC';
    my @entries = @_;
    use Time::Piece;
    use Encode;
    my $entry;
    for ('#mark:hentry') {
        for (@entries) {
            $entry = $_;
            stag;
            content;
            etag;
        }
    }
    for ('#mark:h2') {
        stag;
        print $entry->{title};
        etag;
    }
    for ('#mark:entry-body') {
        stag class => 'content';
        print $entry->{body};
        etag;
    }
    for ('#mark:entry-date') {
        my($attr, $data) = @{$_};
        my $ustrtime = gmtime($entry->{date})->strftime('%FT%TZ');
        my $lstrtime = decode('UTF-8', 
            localtime($entry->{date})->strftime(encode('UTF-8', $data)),
        );
        stag title => $ustrtime, class => 'published';
        print $lstrtime;
        etag;
    }
    END_LOGIC

    my @entries = (
        {title => 'FOO', body => '<b>foo</b> is foo', date => time - 120},
        {title => 'BAR', body => 'bar is bar', date => time - 60},
        {title => 'BAZ', body => 'baz is baz', date => time},
    );

    my $jail = "Text::Xtangle::Jail" . (int rand 200000000);
    my $perl = "package $jail;" . Text::Xtangle->zip($xhtml, $logic);
    my $template = eval $perl;
    print encode('UTF-8', $template->(@entries));
    
    # CSS mode: easy but slow.
    my $xhtml = <<'END_XHTML';
    <div class="hentry">
     <h2></h2>
     <div class="entry-body">RAW</div>
     <div class="entry-date">%Y-%m-%d %H:%M</div>
    </div>
    END_XHTML
    
    my $logic = <<'END_LOGIC';
    my @entries = @_;
    use Time::Piece;
    use Encode;
    my $entry;
    for ('.hentry') {
        # same above '#mark:hentry'
    }
    for ('h2') {
        # same above '#mark:h2'
    }
    for ('.entry-body') {
        # same above '#mark:entry-body'
    }
    for ('.entry-date') {
        # same above '#mark:entry-date'
    }
    END_LOGIC

=head1 DESCRIPTION

This module provides you to generate a template perl source code
from a given XHTML and a presentation logic script similar as
the Kwartz-Ruby template system.

=head1 METHODS 

=over

=item C<zip($xhtml, $logic)>

=item C<get_element($doc_tree, $selector)>

=item C<fold_element($element)>

=item C<document($xhtml)>

=item C<logic($logic)>

=item C<quote(@string)>

=item C<stag(\@template, \%attribute_replacements)>

=item C<escape_raw($string)>

=item C<escape_xml($string)>

=item C<escape_text($string)>

=item C<escape_uri($string)>

=back

=head1 DEPENDENCIES

L<Encode>

=head1 SEE ALSO

L<http://www.kuwata-lab.com/kwartz/>

=head1 AUTHOR

MIZUTANI Tociyuki  C<< <tociyuki@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, MIZUTANI Tociyuki C<< <tociyuki@gmail.com> >>.
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
