#!env perl6

# TODO: basically working, but...
# * --help
# * match date list name
#   argument of 'c' match file named 'contact', if no others starting with 'c'
# * reset day 1: append today's date to file in question

multi sub MAIN () {
	say 'which one?';
}

multi sub MAIN ($which) {
	my $list_dir = %*ENV{'HOME'} ~ '/.day';
	say "days for $which";

	if ("$list_dir/$which".IO ~~ :f & :r) {
		my $days = count_days("$list_dir/$which");
		say "Today is day $days";
	}
	else {
		say "$which is not a readable file! :(";
	}
}

sub count_days (Str $day_file) {
	my $last_line;
	for $day_file.IO.lines -> $line {
		$last_line = $line;
	}

	$last_line ~~ /^
		$<year>=(\d\d\d\d)
		$<month>=(\d\d)
		$<day>=(\d\d)
	$/;
	my $last_date = Date.new($/<year>, $/<month>, $/<day>);

	my $today = Date.new(DateTime.now());

	# we're counting starting with 1, so add 1
	return $today - $last_date + 1;
}
