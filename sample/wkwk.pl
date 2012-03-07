#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<!DOCTYPE html>
<html>
<head>
<title id="mark:title">{{name}} - {{subject}}</title>
</head>
<body>
<h1><a id="mark:bookmark" href="{{script}}/pages/{{name}}">{{name}}</a><span id="mark:subject"> - {{subject}}</span></h1>
<div id="mark:content" class="cpntent-body">{{content|RAW}}</div>
<ul>
<li><a id="mark:front" href="{{script}}/pages/FrontPage">FrontPage</a></li>
<li><a id="mark:edit" href="{{script}}/edit?name={{name}}">Edit</a></li>
<li><a id="mark:recent" href="{{script}}/recent">Recent</a></li>
<li><a id="mark:list" href="{{script}}/pages">List</a></li>
</ul>
</body>
</html>
END_XHTML

my $logic = <<'END_LOGIC';
my($arg) = @_;
my $param = {};
my @accessible = qw(name subject content script);
@{$param}{@accessible} = @{$arg}{@accessible};
for ('#mark:title') {
    stag;
    print $param;
    etag;
}
for ('#mark:bookmark') {
    stag 'href' => $param;
    print $param;
    etag;
}
for ('#mark:subject') {
    print $param;
}
for ('#mark:content') {
    stag;
    print $param;
    etag;
}
for ('#mark:front') {
    stag 'href' => $param;
    content;
    etag;
}
for ('#mark:edit') {
    stag 'href' => $param;
    content;
    etag;
}
for ('#mark:recent') {
    stag 'href' => $param;
    content;
    etag;
}
for ('#mark:list') {
    stag 'href' => $param;
    content;
    etag;
}
END_LOGIC

my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->({
    'name' => 'HelloPage',
    'subject' => 'Hello, World',
    'content' => <<'END_HTML',
<p>quick brown fox jumps over the lazy dog.</p>
END_HTML
    'script' => '/wiki',
});

__END__
<!DOCTYPE html>
<html>
<head>
<title>HelloPage - Hello, World</title>
</head>
<body>
<h1><a href="/wiki/pages/HelloPage">HelloPage</a> - Hello, World</h1>
<div class="cpntent-body"><p>quick brown fox jumps over the lazy dog.</p>
</div>
<ul>
<li><a href="/wiki/pages/FrontPage">FrontPage</a></li>
<li><a href="/wiki/edit?name=HelloPage">Edit</a></li>
<li><a href="/wiki/recent">Recent</a></li>
<li><a href="/wiki/pages">List</a></li>
</ul>
</body>
</html>

