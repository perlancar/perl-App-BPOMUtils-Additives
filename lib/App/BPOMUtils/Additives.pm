package App::BPOMUtils::Additives;

use 5.010001;
use strict;
use warnings;

use Capture::Tiny 'capture_stderr';

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

our %args_common = (
    quantity => {
        # schema => 'physical::mass*', # XXX Perinci::Sub::GetArgs::Argv is not smart enough to coerce from string
        schema => 'str*',
        req => 1,
        pos => 0,
    },
    to_unit => {
        # schema => 'physical::unit', # IU hasn't been added
        schema => 'str*',
        pos => 1,
    },
);

$SPEC{convert_benzoate_unit} = {
    v => 1.1,
    summary => 'Convert a benzoate quantity from one unit to another',
    description => <<'_',

If target unit is not specified, will show all known conversions.

_
    args => {
        %args_common,
    },
    examples => [
        {args=>{quantity=>'ppm'}, summary=>'Show all possible conversions'},
        {args=>{quantity=>'250 ppm', to_unit=>'ppm-as-benzoic-acid'}, summary=>'Convert from ppm (as sodium benzoate) to ppm (as benzoic acid)'},
    ],
};
sub convert_benzoate_unit {
    require Physics::Unit;

    Physics::Unit::InitUnit(
        ['ppm'], '1 mg/kg',
        ['ppm-as-sodium-benzoate'], '1 mg/kg',
        ['ppm-as-benzoic-acid'], '1.18006878480183 mg/kg', # benzoic acid's molecular weight = 122.12, sodium benzoate's molecular weight = 144.11
    );

    my %args = @_;
    my $quantity = Physics::Unit->new($args{quantity});
    return [412, "Must be a Dimensionless quantity"] unless $quantity->type eq 'Dimensionless';

    if ($args{to_unit}) {
        my $new_amount = $quantity->convert($args{to_unit});
        return [200, "OK", $new_amount];
    } else {
        my @rows;
        for my $u (
            'ppm',
            'ppm-as-benzoic-acid',
            'ppm-as-sodium-benzoate',
        ) {
            push @rows, {
                unit => $u,
                amount => $quantity->convert($u),
            };
        }
        [200, "OK", \@rows];
    }
}

1;
#ABSTRACT: Utilities related to food additives in BPOM

=head1 DESCRIPTION

This distributions provides the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<App::BPOMUtils>

=cut
