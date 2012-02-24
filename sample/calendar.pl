#!/usr/bin/env perl
use strict;
use warnings;
use Text::Xtangle;

my $xhtml = <<'END_XHTML';
<table class="calendar">
 <caption></caption>
 <tr><th></th></tr>
 <tr class="week"><td></td></tr>
</table>
END_XHTML

my $logic = <<'END_LOGIC';
my($cal) = @_;
my $week;
for ('.calendar caption') {
    stag;
    print sprintf '%04d-%02d', $cal->year, $cal->month;
    etag;
}
for ('.calendar th') {
    my @wlabel = qw(mo tu we th fr st su);
    for my $w (map { ($_ - $cal->wdoffset) % 7 } 0 .. 6) {
        stag;
        print $wlabel[$w];
        etag;
    }
}
for ('.calendar .week') {
    for my $w (0 .. 5) {
        $week = $w;
        stag class => undef;
        content;
        etag;
    }
}
for ('.calendar td') {
    my $wmonth = $cal->wmonth;
    my $msize = $cal->msize;
    for my $wday (0 .. 6) {
        my $day = $week * 7 + $wday - $wmonth + 1;
        my $t = $day >= 1 && $day <= $msize ? $day : '&nbsp;';
        stag;
        print $t;
        etag;
    }
}
END_LOGIC

my $cal = Calendar->new;
my $template = eval Text::Xtangle->zip($xhtml, $logic);
print $template->($cal);

package Calendar;

# Calendar->new(2010, 5)
# Calendar->new is Calendar->new(localtime)
# Calendar->new(time) is Calendar->new(localtime)
sub new {
    my($class, @arg) = @_;
    my $self = bless {}, $class;
    $self->initialize(@arg);
    return $self;
}

sub year    { return shift->{'year'} }
sub month   { return shift->{'month'} }
sub wdoffset { return shift->{'wdoffset'} }
sub wmonth  { return shift->{'wmonth'} }
sub msize   { return shift->{'msize'} }

sub initialize {
    my($self, @arg) = @_;
    $self->{'wdoffset'} = 0; # 0: mo tu..., 1: su mo tu...
    @{$self}{qw(year month)} = $self->_year_month(@arg);
    use integer;
    my @yday = ([-31,0,31,59,90,120,151,181,212,243,273,304,334,365],
                 [-31,0,31,60,91,121,152,182,213,244,274,305,335,366]);
    my @msize = ([31,31,28,31,30,31,30,31,31,30,31,30,31],
                 [31,31,29,31,30,31,30,31,31,30,31,30,31]);
    my($y, $m) = @{$self}{'year', 'month'};
    my $leap = ($y % 4 == 0 && $y % 100 != 0 || $y % 400 == 0) ? 1 : 0;
    $y--;
    $self->{'wmonth'} = ($y + $y / 4 - $y / 100 + $y / 400
        + $yday[$leap][$m] + $self->{'wdoffset'}) % 7;
    $self->{'msize'} = $msize[$leap][$m];
    return;
}

sub _year_month {
    my($self, @arg) = @_;
    my($year, $month);
    if (@arg == 2) {
        ($year, $month) = @arg;
    }
    else {
        ($year, $month) = (
              @arg > 5 ? @arg
            : @arg == 1 ? (localtime($arg[0]))
            : localtime
        )[5, 4];
        $year += 1900;
        $month++;
    }
    $year > 0 or die "year > 0\n";
    $month >= 1 and $month <= 12 or die "1 <= month <= 12\n";
    return ($year, $month);
}

__END__
<table class="calendar">
 <caption>2010-05</caption>
 <tr><th>mo</th><th>tu</th><th>we</th><th>th</th><th>fr</th><th>st</th><th>su</th></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>1</td><td>2</td></tr>
 <tr><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td></tr>
 <tr><td>10</td><td>11</td><td>12</td><td>13</td><td>14</td><td>15</td><td>16</td></tr>
 <tr><td>17</td><td>18</td><td>19</td><td>20</td><td>21</td><td>22</td><td>23</td></tr>
 <tr><td>24</td><td>25</td><td>26</td><td>27</td><td>28</td><td>29</td><td>30</td></tr>
 <tr><td>31</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</table>

