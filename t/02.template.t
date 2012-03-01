use strict;
use warnings;
use Test::Base;
use Text::Xtangle;

plan tests => 1 * blocks;

run {
    my($blk) = @_;
    my $source = Text::Xtangle->zip($blk->xhtml, $blk->logic);
    my $template = eval $source;
    is $template->(), $blk->expected, $blk->name;
};

__END__

=== <?xml..?><!DOCTYPE>
--- xhtml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja" dir="ltr">
</html>
--- logic
--- expected
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja" dir="ltr">
</html>

=== stag PROP + print TEXT + etag
--- xhtml
<a id="hoge" href="">org.</a>
--- logic
for ('#hoge') {
    stag href => '/hoge.html', title => 'test';
    print 'inner';
    etag;
}
--- expected
<a href="/hoge.html" title="test">inner</a>

=== stag + print TEXT + etag
--- xhtml
<b id="hoge">org.</b>
--- logic
for ('#hoge') {
    stag;
    print 'inner';
    etag;
}
--- expected
<b>inner</b>

=== stag PROP + content + etag
--- xhtml
<a id="hoge" href="">org.</a>
--- logic
for ('#hoge') {
    stag href => '/hoge.html', title => 'test';
    content;
    etag;
}
--- expected
<a href="/hoge.html" title="test">org.</a>

=== stag + content + etag
--- xhtml
<a id="hoge" href="/hoge.html">org.</a>
--- logic
for ('#hoge') {
    stag;
    content;
    etag;
}
--- expected
<a href="/hoge.html">org.</a>

=== element
--- xhtml
<a id="hoge" href="/hoge.html">org.</a>
--- logic
for ('#hoge') {
    element;
}
--- expected
<a href="/hoge.html">org.</a>

=== hoge-inner
--- xhtml
<b id="hoge">org.</b>
--- logic
for ('#hoge') {
    stag id => 'hoge';
    print 'inner';
    etag;
}
--- expected
<b id="hoge">inner</b>

=== inner escape_text
--- xhtml
<b id="hoge">org.</b>
--- logic
for ('#hoge') {
    stag;
    print '<&>"&nbsp;';
    etag;
}
--- expected
<b>&lt;&amp;&gt;&quot;&nbsp;</b>

=== inner escape_xml
--- xhtml
<textarea id="hoge">org.</textarea>
--- logic
for ('#hoge') {
    stag;
    print '<&>"&nbsp;';
    etag;
}
--- expected
<textarea>&lt;&amp;&gt;&quot;&amp;nbsp;</textarea>

=== inner modifier
--- xhtml
<a>XML</a>
<b>HTML</b>
<c>RAW</c>
<d>TEXT</d>
<e>default</e>
--- logic
for ('a') {
    stag;
    print '<&>"&amp;&nbsp;\\';
    etag;
}
for ('b') {
    stag;
    print '<&>"&amp;&nbsp;\\';
    etag;
}
for ('c') {
    stag;
    print '<&>"&amp;&nbsp;\\';
    etag;
}
for ('d') {
    stag;
    print '<&>"&amp;&nbsp;\\';
    etag;
}
for ('e') {
    stag;
    print '<&>"&amp;&nbsp;\\';
    etag;
}
--- expected
<a>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;&#92;</a>
<b>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;&#92;</b>
<c><&>"&amp;&nbsp;\</c>
<d>&lt;&amp;&gt;&quot;&amp;&nbsp;&#92;</d>
<e>&lt;&amp;&gt;&quot;&amp;&nbsp;&#92;</e>

=== tagname tagname
--- xhtml
<p><code><span></span></code></p>
<div><code><span></span></code></div>
--- logic
for ('p span') {
    print 'paragraph';
}
for ('div span') {
    print 'division';
}
--- expected
<p><code>paragraph</code></p>
<div><code>division</code></div>

=== id tagname
--- xhtml
<p id="foo"><span></span></p>
<p id="bar"><span></span></p>
--- logic
for ('#foo span') {
    print 'FOO';
}
for ('#bar span') {
    print 'BAR';
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== tagnameid tagname
--- xhtml
<p id="foo"><span></span></p>
<p id="bar"><span></span></p>
--- logic
for ('p#foo span') {
    print 'FOO';
}
for ('p#bar span') {
    print 'BAR';
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== tagname[id=""] tagname
--- xhtml
<p id="foo"><span></span></p>
<p id="bar"><span></span></p>
--- logic
for ('p[id="foo"] span') {
    print 'FOO';
}
for ('p[id="bar"] span') {
    print 'BAR';
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== .class
--- xhtml
<p class="foo"></p>
<p class="bar foo"></p>
--- logic
for ('.foo') {
    stag;
    print 'FOO';
    etag;
}
--- expected
<p class="foo">FOO</p>
<p class="bar foo">FOO</p>

=== [class~="foo"]
--- xhtml
<p class="foo"></p>
<p class="bar foo"></p>
--- logic
for ('[class~="foo"]') {
    stag;
    print 'FOO';
    etag;
}
--- expected
<p class="foo">FOO</p>
<p class="bar foo">FOO</p>

=== [class^="foo"]
--- xhtml
<p class="foo"></p>
<p class="foo bar"></p>
<p class="bar foo">bar</p>
--- logic
for ('[class^="foo"]') {
    stag;
    print 'FOO';
    etag;
}
--- expected
<p class="foo">FOO</p>
<p class="foo bar">FOO</p>
<p class="bar foo">bar</p>

=== [class$="foo"]
--- xhtml
<p class="foo"></p>
<p class="foo bar">bar</p>
<p class="bar foo"></p>
--- logic
for ('[class$="foo"]') {
    stag;
    print 'FOO';
    etag;
}
--- expected
<p class="foo">FOO</p>
<p class="foo bar">bar</p>
<p class="bar foo">FOO</p>

=== [class*="oo"]
--- xhtml
<p class="foo"></p>
<p class="bar">bar</p>
<p class="bar foo"></p>
--- logic
for ('[class*="oo"]') {
    stag;
    print 'ok';
    etag;
}
--- expected
<p class="foo">ok</p>
<p class="bar">bar</p>
<p class="bar foo">ok</p>

=== [class|="entry"]
--- xhtml
<p class="entry">not ok</p>
<p class="entry-body">not ok</p>
<p class="hentry-body">not ok</p>
--- logic
for ('[class|="entry"]') {
    stag;
    print 'ok';
    etag;
}
--- expected
<p class="entry">ok</p>
<p class="entry-body">ok</p>
<p class="hentry-body">not ok</p>

=== .class tagname
--- xhtml
<p class="foo"><span></span></p>
<p class="bar"><span></span></p>
--- logic
for ('.foo span') {
    print 'FOO';
}
for ('.bar span') {
    print 'BAR';
}
--- expected
<p class="foo">FOO</p>
<p class="bar">BAR</p>

=== tagname.class tagname
--- xhtml
<p class="foo"><span></span></p>
<p class="bar"><span></span></p>
--- logic
for ('p.foo span') {
    print 'FOO';
}
for ('p.bar span') {
    print 'BAR';
}
--- expected
<p class="foo">FOO</p>
<p class="bar">BAR</p>

=== skip tag
--- xhtml
<p><b id="hoge">org.</b></p>
--- logic
for ('#hoge') {
    print 'outer';
}
--- expected
<p>outer</p>

=== skip tag escape_text
--- xhtml
<p><b id="hoge">org.</b></p>
--- logic
for ('#hoge') {
    print '<&>"&nbsp;';
}
--- expected
<p>&lt;&amp;&gt;&quot;&nbsp;</p>

=== skip tag RAW
--- xhtml
<p><b id="hoge">RAW</b></p>
--- logic
for ('#hoge') {
    print '<![CDATA[<&>"&nbsp;]]>';
}
--- expected
<p><![CDATA[<&>"&nbsp;]]></p>

=== drop id
--- xhtml
<span><b><span id="foo">&nbsp;</span></b></span>
--- logic
for ('#foo') {
    stag;
    print 'test';
    etag;
}
--- expected
<span><b><span>test</span></b></span>

=== pass class
--- xhtml
<span><b><span class="foo">&nbsp;</span></b></span>
--- logic
for ('.foo') {
    stag;
    print 'test';
    etag;
}
--- expected
<span><b><span class="foo">test</span></b></span>

=== empty inner
--- xhtml
<link id="hoge" />
--- logic
for ('link') {
    stag;
    print 'FOO';
    etag;
}
--- expected
<link />

=== empty inner-id
--- xhtml
<link id="hoge" />
--- logic
for ('link') {
    stag id => 'hoge';
    print 'FOO';
    etag;
}
--- expected
<link id="hoge" />

=== empty skip tag
--- xhtml
<link id="hoge" />FOO
--- logic
for ('link') {
    print 'BAR';
}
--- expected
FOO

=== attribute default filter
--- xhtml
<link href=""
 src=""
 cite=""
 title=""
 rdf:resource=""/>
--- logic
for ('link') {
    stag
        'href' => '&<>"\\&amp;%12%45%+',
        'src' => '&<>"\\&amp;%12%45%+',
        'cite' => '&<>"\\&amp;%12%45%+',
        'title' => '&<>"\\&amp;%12%45%+',
        'rdf:resource' => '&<>"\\&amp;%12%45%+';
}
--- expected
<link href="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 src="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 cite="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 title="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"
 rdf:resource="&amp;%3C%3E%22%5C&amp;%12%45%25+"/>

=== attribute input default filter
--- xhtml
<input type="hidden"
    name=""
    value="" />
--- logic
for ('input') {
    stag name => '&<>"\\&amp;%12%45%+',
        value => '&<>"\\&amp;%12%45%+';
}
--- expected 
<input type="hidden"
    name="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"
    value="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+" />

=== attribute modifier
--- xhtml
<link a="URI"
 b="URL"
 c="XML"
 d="HTML"
 e="RAW"
 f="TEXT"/>
--- logic
for ('link') {
    stag
        'a' => '&<>"\\&amp;%12%45%+',
        'b' => '&<>"\\&amp;%12%45%+',
        'c' => '&<>"\\&amp;%12%45%+',
        'd' => '&<>"\\&amp;%12%45%+',
        'e' => '&<>&amp;%12%45%+',
        'f' => '&<>"\\&amp;%12%45%+';
}
--- expected
<link a="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 b="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 c="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+"
 d="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+"
 e="&<>&amp;%12%45%+"
 f="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"/>

=== add attribute
--- xhtml
<b id="hoge" title="fuga">org.</b>
--- logic
for ('#hoge') {
    stag class => 'bold';
    content;
    etag;
}
--- expected
<b title="fuga" class="bold">org.</b>

=== delete attribute
--- xhtml
<b id="hoge" title="fuga">org.</b>
--- logic
for ('#hoge') {
    stag title => undef;
    content;
    etag;
}
--- expected
<b>org.</b>

=== replace attribute
--- xhtml
<a id="hoge" href="foo">org.</a>
--- logic
for ('#hoge') {
    stag href => 'bar';
    content;
    etag;
}
--- expected
<a href="bar">org.</a>

=== do not yield
--- xhtml
<b>foo<a id="hoge" href="foo">org.</a></b>
--- logic
for ('#hoge') {
}
--- expected
<b>foo</b>

=== <style>CDATA</style>
--- xhtml
<style type="text/css"><![CDATA[
 .c > .d {color:red}
]]></style>
--- logic
for ('style') {
    element;
}
--- expected
<style type="text/css"><![CDATA[
 .c > .d {color:red}
]]></style>

=== <script>CDATA</script>
--- xhtml
<script>//<![CDATA[
if (hoge<fuga) { fuga(); }
]]></script>
--- logic
for ('script') {
    stag type => 'text/javascript';
    content;
    etag;
}
--- expected
<script type="text/javascript">//<![CDATA[
if (hoge<fuga) { fuga(); }
]]></script>

=== leave id
--- xhtml
<h1></h1>
<p id="asis"><a id="foo" href=""></a></p>
--- logic
for ('h1') {
    stag;
    print 'Hello, World';
    etag;
}
for ('#foo') {
    stag href => 'http://www.w3.org';
    print 'W3C';
    etag;
}
--- expected
<h1>Hello, World</h1>
<p id="asis"><a href="http://www.w3.org">W3C</a></p>

=== repeated yield
--- xhtml
<ul>
 <li></li>
</ul>
--- logic
for ('li') {
    for my $v ('A' .. 'C') {
        stag $v eq 'B' ? (class => 'here') : ();
        print $v;
        etag;
    }
}
--- expected
<ul>
 <li>A</li>
 <li class="here">B</li>
 <li>C</li>
</ul>

=== RDF
--- xhtml
<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:wot="http://xmlns.com/wot/0.1/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="ja">
<foaf:Person rdf:ID="tociyuki">
 <foaf:mbox_sha1sum id="sha1"></foaf:mbox_sha1sum>
 <foaf:name>MIZUTANI, Tociyuki</foaf:name>
 <foaf:weblog id="blog" dc:title="" />
</foaf:Person>
</rdf:RDF>
--- logic
for ('#sha1') {
    stag;
    print '46f39be840c113a8d654aff099814f49bb5639b6';
    etag;
}
for ('#blog') {
    stag
        'rdf:resource' => "http://d.hatena.ne.jp/tociyuki/",
        'dc:title' => "Tociyuki::Diary";
}
--- expected
<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:wot="http://xmlns.com/wot/0.1/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="ja">
<foaf:Person rdf:ID="tociyuki">
 <foaf:mbox_sha1sum>46f39be840c113a8d654aff099814f49bb5639b6</foaf:mbox_sha1sum>
 <foaf:name>MIZUTANI, Tociyuki</foaf:name>
 <foaf:weblog dc:title="Tociyuki::Diary" rdf:resource="http://d.hatena.ne.jp/tociyuki/" />
</foaf:Person>
</rdf:RDF>

=== demo get attribute and data
--- xhtml
<html>
 <body>
  <h1><a id="mark:a1" href="replaced">replacing attributes</a></h1>
  <p><a id="mark:a2" href="http://example.net/">examples</a></p>
  <p><a id="mark:a3" href="http://d.hatena.ne.jp/$1/$2">id:$1:$2</a></p>
 </body>
</html>
--- logic
for ('#mark:a1') {
    stag href => 'http://hoge.gr.jp/';
    content;
    etag;
}
for ('#mark:a2') {
    my($attr, $data) = @{$_};
    stag href => $attr->{'href'} . 'ja/';
    print $data . ' (Japanese)';
    etag;
}
for ('#mark:a3') {
    my($attr, $data) = @{$_};
    my @path = ('someone', 132424);
    my $href = $attr->{'href'};
    $href =~ s{[\$]([12])}{ $path[$1 - 1] }egmsx;
    $data =~ s{[\$]([12])}{ $path[$1 - 1] }egmsx;
    stag href => $href;
    print $data;
    etag;
}
--- expected
<html>
 <body>
  <h1><a href="http://hoge.gr.jp/">replacing attributes</a></h1>
  <p><a href="http://example.net/ja/">examples (Japanese)</a></p>
  <p><a href="http://d.hatena.ne.jp/someone/132424">id:someone:132424</a></p>
 </body>
</html>

=== demo cond (ID-only mode)
--- xhtml
<html>
 <body>
  <h1>conditional</h1>
  <div id="mark:cond">
  <h2 id="mark:title"></h2>
  <p id="mark:zero">no data.</p>
  <p id="mark:one">one: <span id="mark:one-value">data</span>.</p>
  <ul id="mark:many">
   <li id="mark:many-each"></li>
  </ul>
  </div>
 </body>
</html>
--- logic
my @param = (
    {'title' => 'three', 'many' => [qw(1 2 3)]},
    {'title' => 'zero', 'zero' => 0},
    {'title' => 'one', 'one' => 1},
);
my $cond;
for ('#mark:cond') {
    for my $c (@param) {
        $cond = $c;
        content;
    }
}
for ('#mark:title') {
    stag;
    print $cond->{'title'};
    etag;
}
for ('#mark:zero') {
    if (exists $cond->{'zero'}) {
        element;
    }
}
for ('#mark:one') {
    if (exists $cond->{'one'}) {
        element;
    }
}
for ('#mark:one-value') {
    print $cond->{'one'};
}
for ('#mark:many') {
    if (exists $cond->{'many'}) {
        element;
    }
}
for ('#mark:many-each') {
    for my $x (@{$cond->{'many'}}) {
        stag;
        print $x;
        etag;
    }
}
--- expected
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

=== demo cond (CSS mode)
--- xhtml
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
--- logic
my $param = [
    {'title' => 'three', 'many' => [qw(1 2 3)]},
    {'title' => 'zero', 'zero' => 0},
    {'title' => 'one', 'one' => 1},
];
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
--- expected
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

=== demo dt dd (ID-only mode)
--- xhtml
<dl id="mark:dl">
 <dt id="mark:dt"></dt>
 <dd id="mark:dd"></dd>
</dl>
--- logic
my @symbol = qw(dollar scalar atmark array percent hash);
my($t, $d);
for ('#mark:dl') {
    stag;
    while (($t, $d) = splice @symbol, 0, 2) {
        content;
    }
    etag;
}
for ('#mark:dt') {
    stag;
    print $t;
    etag;
}
for ('#mark:dd') {
    stag;
    print $d;
    etag;
}
--- expected
<dl>
 <dt>dollar</dt>
 <dd>scalar</dd>
 <dt>atmark</dt>
 <dd>array</dd>
 <dt>percent</dt>
 <dd>hash</dd>
</dl>

=== demo dt dd (CSS-mode)
--- xhtml
<dl>
 <dt></dt>
 <dd></dd>
</dl>
--- logic
my @symbol = qw(dollar scalar atmark array percent hash);
my($t, $d);
for ('dl') {
    stag;
    while (($t, $d) = splice @symbol, 0, 2) {
        content;
    }
    etag;
}
for ('dt') {
    stag;
    print $t;
    etag;
}
for ('dd') {
    stag;
    print $d;
    etag;
}
--- expected
<dl>
 <dt>dollar</dt>
 <dd>scalar</dd>
 <dt>atmark</dt>
 <dd>array</dd>
 <dt>percent</dt>
 <dd>hash</dd>
</dl>

=== demo form (ID-only mode)
--- xhtml
<html>
 <body>
  <form id="mark:form1">
   <select name="f0">
    <option id="mark:f0-eachoption"></option>
   </select>
   <input id="mark:f1" type="text" name="f1" />
   <textarea id="mark:f2" name="f2"></textarea>
   <select name="f3">
    <option id="mark:f3-0" value="f3a">F3A</option>
    <option id="mark:f3-1" value="f3b">F3B</option>
    <option id="mark:f3-2" value="f3c">F3C</option>
   </select>
   <div id="mark:f4g">
   <input id="mark:f4" type="checkbox" name="f4" /><span id="mark:f4v">&nbsp;</span>,
   </div>
   <input id="mark:f5-0" type="radio" name="f5" value="a" />A,
   <input id="mark:f5-1" type="radio" name="f5" value="b" />B,
   <input id="mark:f5-2" type="radio" name="f5" value="c" />C,
  </form>
 </body>
</html>
--- logic
my($value, $label);
for ('#mark:form1') {
    stag method => 'post', action => 'hoge';
    content;
    etag;
}
for ('#mark:f0-eachoption') {
    my $sel = 'f0c';
    for my $v (qw(f0a f0b f0c f0d)) {
        my @selected = $sel eq $v ? (selected => 'selected') : ();
        stag value => $v, @selected;
        print uc $v;
        etag;
    }
}
for ('#mark:f1') {
    stag value => 'hoge <&nbsp;">';
}
for ('#mark:f2') {
    stag;
    print 'fuga <&nbsp;">';
    etag;
}
for ('#mark:f3-0') {
    my($attr, $data) = @{$_};
    stag $attr->{'value'} eq 'f3b' ? ('selected' => 'selected') : ();
    content;
    etag;
}
for ('#mark:f3-1') {
    my($attr, $data) = @{$_};
    stag $attr->{'value'} eq 'f3b' ? ('selected' => 'selected') : ();
    content;
    etag;
}
for ('#mark:f3-2') {
    my($attr, $data) = @{$_};
    stag $attr->{'value'} eq 'f3b' ? ('selected' => 'selected') : ();
    content;
    etag;
}
for ('#mark:f4g') {
    for my $v (qw(foo bar baz)) {
        ($value, $label) = ($v, uc $v);
        content;
    }
}
for ('#mark:f4') {
    stag value => $value;
}
for ('#mark:f4v') {
    print $label;
}
for ('#mark:f5-0') {
    my($attr) = @{$_};
    stag $attr->{'value'} eq 'a' ? ('checked' => 'checked') : ();
}
for ('#mark:f5-1') {
    my($attr) = @{$_};
    stag $attr->{'value'} eq 'a' ? ('checked' => 'checked') : ();
}
for ('#mark:f5-2') {
    my($attr) = @{$_};
    stag $attr->{'value'} eq 'a' ? ('checked' => 'checked') : ();
}
--- expected
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

=== demo form (CSS-mode)
--- xhtml
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
--- logic
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
--- expected
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

=== demo table (ID-only mode)
--- xhtml
<table>
 <caption id="mark:caption"></caption>
 <tr id="mark:tr">
  <td id="mark:td"></td>
 </tr>
</table>
--- logic
my @rows = (
    [{'width' => '32', 'align' => 'left'}, 'L1', 'L2'],
    [{'align' => 'center', 'colspan' => 2}, 'C1'],
    [{'align' => 'right'}, 'R1', 'R2'],
);
my $row;
for ('#mark:caption') {
    stag;
    print 'ABC';
    etag;
}
for ('#mark:tr') {
    for (@rows) {
        $row = $_;
        element;
    }
}
for ('#mark:td') {
    my($attr, @col) = @{$row};
    for my $c (@col) {
        stag %{$attr};
        print $c;
        etag;
    }
}
--- expected
<table>
 <caption>ABC</caption>
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

=== demo table (CSS mode)
--- xhtml
<table>
 <caption></caption>
 <tr>
  <td></td>
 </tr>
</table>
--- logic
my @rows = (
    [{'width' => '32', 'align' => 'left'}, 'L1', 'L2'],
    [{'align' => 'center', 'colspan' => 2}, 'C1'],
    [{'align' => 'right'}, 'R1', 'R2'],
);
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
--- expected
<table>
 <caption>ABC</caption>
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

=== demo calendar
--- xhtml
<table class="calendar">
 <caption id="mark:caltitle"></caption>
 <tr><th id="mark:calweeklabel">mo tu we th fr st su</th></tr>
 <tr id="mark:calweek"><td id="mark:calday">&nbsp;</td></tr>
</table>
--- logic
my($year, $month) = (2012, 3);
my $wdoffset = 0;
my @yday = (
    [-31, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
    [-31, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366],
);
my @msize = (
    [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    [31, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
);
my $leap = ($year % 4 == 0 && $year % 100 != 0 || $year % 400 == 0) ? 1 : 0;
my $y = $year - 1;
my $wmonth = ($y + (int $y / 4) - (int $y / 100) + (int $y / 400)
    + $yday[$leap][$month] + $wdoffset) % 7;
my $msize = $msize[$leap][$month];
for ('#mark:caltitle') {
    stag;
    print sprintf '%04d-%02d', $year, $month;
    etag;
}
for ('#mark:calweeklabel') {
    my @wlabel = split /\s+/, $_->[1];
    for my $w (map { ($_ - $wdoffset) % 7 } 0 .. 6) {
        stag;
        print $wlabel[$w];
        etag;
    }
}
for ('#mark:calweek') {
    for my $week (0 .. 5) {
        stag class => undef;
        content;
            # expand C<for ('.calendar .week td')> here.
        etag;
    }
}
for ('#mark:calday') {
    for my $wday (0 .. 6) {
        stag;
        my $day = $week * 7 + $wday - $wmonth + 1;
        if ($day >= 1 && $day <= $msize) {
            print $day;
        }
        else {
            content;
        }
        etag;
    }
}
--- expected
<table class="calendar">
 <caption>2012-03</caption>
 <tr><th>mo</th><th>tu</th><th>we</th><th>th</th><th>fr</th><th>st</th><th>su</th></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>
 <tr><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td></tr>
 <tr><td>12</td><td>13</td><td>14</td><td>15</td><td>16</td><td>17</td><td>18</td></tr>
 <tr><td>19</td><td>20</td><td>21</td><td>22</td><td>23</td><td>24</td><td>25</td></tr>
 <tr><td>26</td><td>27</td><td>28</td><td>29</td><td>30</td><td>31</td><td>&nbsp;</td></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</table>

=== demo linklist 10
--- xhtml
<div class="linklist">
<span id="curno"></span>/<span id="totals"></span> :
<a id="prevfirst" href="index.html">front</a>
<a id="prevlink" href="">prev</a>
|
<a id="indexlink" href="index.html">front</a>
<span id="indexhere" class="here">front</span>
<span id="pagelinks">
<a id="pagelink" href=""></a><span id="pagehere" class="here"></span><span id="pagecomma">,</span> 
</span>
|
<a id="nextlink" href="">next</a>
<a id="nextlast" href="index.html">front</a>
</div>
--- logic
my $cur = 10;
my $links = [map { sprintf "r%02d.html", $_ } 0 .. 35];
my $list_width = 7;
my $length = @{$links};
my $w = $list_width > $length ? $length : $list_width;
my $lefts = int(($w + 1) / 2) - 1;
my $rights = $w - $lefts;
my $listhead = $cur <= $lefts ? 0
    : $cur >= $length - $rights ? $length - $w
    : $cur - $lefts;
my $listtail = $listhead + $w - 1;
my $item;
for ('#curno') { 
    print $cur + 1;
}
for ('#totals') {
    print scalar @{$links};
}
for ('#prevfirst') {
    if ($cur <= 0) {
        element;
    }
}
for ('#prevlink') {
    if ($cur > 0) {
        stag href => $links->[$cur - 1];
        content;
        etag;
    }
}
for ('#nextlink') {
    if ($cur < $length - 1) {
        stag href => $links->[$cur + 1];
        content;
        etag;
    }
}
for ('#nextlast') {
    if ($cur >= $length - 1) {
        element;
    }
}
for ('#indexlink') {
    element;
}
for ('#indexhere') {
    # do nothing;
}
for ('#pagelinks') {
    for my $i ($listhead .. $listtail) {
        $item = $i;
        content;
    }
}
for ('#pagelink') {
    if ($item != $cur) {
        stag href => $links->[$item];
        print $item + 1;
        etag;
    }
}
for ('#pagehere') {
    if ($item == $cur) {
        stag;
        print $item + 1;
        etag;
    }
}
for ('#pagecomma') {
    if ($item != $listtail) {
        content;
    }
}
--- expected
<div class="linklist">
11/36 :
<a href="r09.html">prev</a>
|
<a href="index.html">front</a>
<a href="r07.html">8</a>, 
<a href="r08.html">9</a>, 
<a href="r09.html">10</a>, 
<span class="here">11</span>, 
<a href="r11.html">12</a>, 
<a href="r12.html">13</a>, 
<a href="r13.html">14</a> 
|
<a href="r11.html">next</a>
</div>

