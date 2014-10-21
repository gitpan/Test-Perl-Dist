#!/usr/bin/perl

# Test that modules pass perlcritic and perltidy.

use strict;

BEGIN {
	use English qw(-no_match_vars);
	$OUTPUT_AUTOFLUSH = 1;
	$WARNING = 1;
}

my @MODULES = (
    'Perl::Tidy',
	'Perl::Critic',
	'PPIx::Regexp',
	'Email::Address',
	'Perl::Critic::Utils::Constants',
	'Perl::Critic::More',
	'Test::Perl::Critic',
);

# Load the testing modules
use Test::More;
foreach my $MODULE ( @MODULES ) {
	eval "require $MODULE"; # Has to be require because we pass options to import.
	if ( $EVAL_ERROR ) {
		BAIL_OUT( "Failed to load required release-testing module $MODULE" )
	}
}

if ( 1.099_001 > eval { $Perl::Critic::VERSION } ) {
	plan( skip_all => "Perl::Critic needs updated to 1.099_001" );
}

if ( 20090616 > eval { $Perl::Tidy::VERSION } ) {
	plan( skip_all => "Perl::Tidy needs updated to 20090616" );
}

use File::Spec::Functions qw(catfile);
Perl::Critic::Utils::Constants->import(':profile_strictness');
my $dummy = $Perl::Critic::Utils::Constants::PROFILE_STRICTNESS_QUIET;

local $ENV{PERLTIDY} = catfile(qw(xt settings perltidy.txt));

my $rcfile = catfile(qw(xt settings perlcritic.txt));
Test::Perl::Critic->import( 
	-profile            => $rcfile, 
	-severity           => 1, 
	-profile-strictness => $Perl::Critic::Utils::Constants::PROFILE_STRICTNESS_QUIET
);

all_critic_ok();
