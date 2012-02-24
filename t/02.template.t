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

