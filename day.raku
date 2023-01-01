#!env raku

# basically working, but...
# * --help
# * match date list name -- DONE
#   argument of 'c' match file named 'contacts', if no others starting with 'c'
#   case-insensitive too
# * reset day 1: append today's date to file in question -- DONE
#   allow a day offset when resetting: -1 means yesterday was day 1
# * given a date, what day was that?
#   subtract from a different date (prior day-1)
# * create a new day tracker
#   --new or somesuch?
# * abbreviated list name matches more than one -- DONE
#   e.g., 'foo' and 'furnace'
#   prompt to be more specific, show potential matches

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
		my Str $expanded = expand_file_arg($which, $list_dir);

		if ( not $expanded ) {
			say "Didn't find any matches for '$which'";
			exit 1;
		}

		reset-day($expanded, $ago);
		exit 0;
	}
	elsif ($which) {
		my Str $expanded = expand_file_arg($which, $list_dir);

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

multi sub MAIN () {
	say 'Which day?';
	say 'Choice of: ' ~ join ', ', sort map { .basename }, dir $list_dir;
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

	my @matched;

	for @found -> $f {
		if ( $f ~~ m:i/^$subfile/ ) {
			push @matched, $f;
		}
	}

	if ( not @matched ) {
		# didn't find anything
		return '';
	}
	elsif ( 1 == @matched.elems ) {
		return @matched[0];
	}
	else {
		# matched more than 1
		say "Be more specific. Matched: " ~ join ', ', @matched;
		return '';
	}
}

sub reset-day (Str $day-file, Int $days) {
	my $new-day = Date.today() - $days;

	my $new-day-string = sprintf('%04d%02d%02d', $new-day.year, $new-day.month, $new-day.day);
	say "Resetting $day-file! Ago: $days; Date: $new-day-string";

	unless my $day-handle = open "$list_dir/$day-file", :a {
		die "Could not open '$day-file': {$day-handle.exception}";
	}

	$day-handle.say($new-day-string);
}
