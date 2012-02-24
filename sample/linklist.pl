#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<div class="linklist">
<span id="curno"></span>/<span id="totals"></span> :
<a id="prevfirst" href="index.html">front</a>
<a id="prevlink" href="">prev</a>
|
<a id="indexlink" href="index.html">front</a>
<span id="indexhere" class="here">front</span>
<span id="pagelinks">
<a href=""></a><span class="here"></span><span class="comma">,</span> 
</span>
|
<a id="nextlink" href="">next</a>
<a id="nextlast" href="index.html">front</a>
</div>

END_XHTML

my $logic = <<'END_LOGIC';
my($cur, $links, $list_width) = @_;
$list_width ||= 7;
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
for ('#pagelinks a') {
    if ($item != $cur) {
        stag href => $links->[$item];
        print $item + 1;
        etag;
    }
}
for ('#pagelinks .here') {
    if ($item == $cur) {
        stag;
        print $item + 1;
        etag;
    }
}
for ('#pagelinks .comma') {
    if ($item != $listtail) {
        content;
    }
}
END_LOGIC

my $links = [map { sprintf "r%02d.html", $_ } 0 .. 35];

my $template = eval Text::Xtangle->zip($xhtml, $logic) or die "$@";
print $template->(0, $links);
print $template->(2, $links);
print $template->(10, $links);
print $template->(35, $links);

__END__
<div class="linklist">
1/36 :
<a href="index.html">front</a>
|
<a href="index.html">front</a>
<span class="here">1</span>,
<a href="r01.html">2</a>,
<a href="r02.html">3</a>,
<a href="r03.html">4</a>,
<a href="r04.html">5</a>,
<a href="r05.html">6</a>,
<a href="r06.html">7</a>
|
<a href="r01.html">next</a>
</div>

<div class="linklist">
3/36 :
<a href="r01.html">prev</a>
|
<a href="index.html">front</a>
<a href="r00.html">1</a>,
<a href="r01.html">2</a>,
<span class="here">3</span>,
<a href="r03.html">4</a>,
<a href="r04.html">5</a>,
<a href="r05.html">6</a>,
<a href="r06.html">7</a>
|
<a href="r03.html">next</a>
</div>

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

<div class="linklist">
36/36 :
<a href="r34.html">prev</a>
|
<a href="index.html">front</a>
<a href="r29.html">30</a>,
<a href="r30.html">31</a>,
<a href="r31.html">32</a>,
<a href="r32.html">33</a>,
<a href="r33.html">34</a>,
<a href="r34.html">35</a>,
<span class="here">36</span>
|
<a href="index.html">front</a>
</div>

