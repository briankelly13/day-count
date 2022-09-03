#!env perl6

# basically working, but...
# * --help
# * match date list name -- DONE
#   argument of 'c' match file named 'contact', if no others starting with 'c'
#   case-insensitive too
# * reset day 1: append today's date to file in question
#   allow a day offset when resetting: -1 means yesterday was day 1
# * given a date, what day was that?
#   subtract from a different date (prior day-1)

my $list_dir = %*ENV{'HOME'} ~ '/.day';

multi sub MAIN () {
	say 'which one?';
	say 'Choice of: ' ~ join ' ', map { .basename }, dir $list_dir;
	exit 1;
}

multi sub MAIN ($which) {

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
