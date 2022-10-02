#!env raku

# basically working, but...
# * --help
# * match date list name -- DONE
#   argument of 'c' match file named 'contacts', if no others starting with 'c'
#   case-insensitive too
# * reset day 1: append today's date to file in question
#   allow a day offset when resetting: -1 means yesterday was day 1
# * given a date, what day was that?
#   subtract from a different date (prior day-1)

my %*SUB-MAIN-OPTS =
  :named-anywhere,    # allow named variables at any location
;

my $list_dir = %*ENV{'HOME'} ~ '/.day';

multi sub MAIN (
	Str $which,
	Int $ago = 0,
	Bool :$reset = False,
) {
	if ($reset) {
		if (not $which) {
			say 'Which to reset?';
			exit 1;
		}
		my $expanded = expand_file_arg($which, $list_dir);

		reset-day($expanded, $ago);
		exit 0;
	}
	elsif ($which) {
		my $expanded = expand_file_arg($which, $list_dir);

		if ( not $expanded ) {
			say "Could not find file matching '$which'";
			exit 1;
		}
		elsif ("$list_dir/$expanded".IO ~~ :f & :r) {
			my $days = count_days("$list_dir/$expanded");
			say "Today is $expanded day $days";
			exit 0;
		}
		else {
			say "$expanded is not a readable file! :(";
			exit 1;
		}
	}
	elsif ( not $which ) {
		say 'which one?';
		say 'Choice of: ' ~ join ', ', sort map { .basename }, dir $list_dir;
		exit 1;
	}
}

multi sub MAIN (
	Bool :$help = False,
) {
	say "Help? $help";
	if ( not $help ) {
		say 'which one?';
		say 'Choice of: ' ~ join ', ', sort map { .basename }, dir $list_dir;
		exit 1;
	}
	else {

	}
}

multi sub MAIN (
	Bool :$reset = False,
) {
	say 'Which to reset?';
	exit 1;
}

sub count_days (Str $day_file) {
	my $last_line = $day_file.IO.lines.tail;

	my $last_date;
	if ( $last_line and $last_line ~~ /^
		$<year>=(\d\d\d\d)
		$<month>=(\d\d)
		$<day>=(\d\d)
	$/ ) {
		$last_date = Date.new($/<year>, $/<month>, $/<day>);
	}
	else {
		die "Could not read last date from '$day_file'";
	}

	# we're counting starting with 1, so add 1
	return Date.today() - $last_date + 1;
}

sub expand_file_arg ($subfile, $dir) {
	# get a basenamed list of possible files, sorted by name length
	my @found = sort -> $a, $b {$a.chars <=> $b.chars}, map { .basename }, dir $dir;

	my $matched;
	for @found -> $f {
		if ( $f ~~ m:i/^$subfile/ ) {
			$matched = $f;
		}
	}

	return $matched;
}

sub reset-day ($day-file, $days) {
	say "Reset $day-file! Ago: $days";
	#TBI
}
