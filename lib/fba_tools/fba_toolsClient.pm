package fba_tools::fba_toolsClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

fba_tools::fba_toolsClient

=head1 DESCRIPTION


A KBase module: fba_tools
This module contains the implementation for the primary methods in KBase for metabolic model reconstruction, gapfilling, and analysis


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => fba_tools::fba_toolsClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 build_metabolic_model

  $return = $obj->build_metabolic_model($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.BuildMetabolicModelParams
$return is a fba_tools.BuildMetabolicModelResults
BuildMetabolicModelParams is a reference to a hash where the following keys are defined:
	genome_id has a value which is a fba_tools.genome_id
	genome_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	template_id has a value which is a fba_tools.template_id
	template_workspace has a value which is a fba_tools.workspace_name
	coremodel has a value which is a fba_tools.bool
	gapfill_model has a value which is a fba_tools.bool
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
genome_id is a string
workspace_name is a string
media_id is a string
fbamodel_id is a string
template_id is a string
bool is an int
compound_id is a string
expseries_id is a string
BuildMetabolicModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.BuildMetabolicModelParams
$return is a fba_tools.BuildMetabolicModelResults
BuildMetabolicModelParams is a reference to a hash where the following keys are defined:
	genome_id has a value which is a fba_tools.genome_id
	genome_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	template_id has a value which is a fba_tools.template_id
	template_workspace has a value which is a fba_tools.workspace_name
	coremodel has a value which is a fba_tools.bool
	gapfill_model has a value which is a fba_tools.bool
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
genome_id is a string
workspace_name is a string
media_id is a string
fbamodel_id is a string
template_id is a string
bool is an int
compound_id is a string
expseries_id is a string
BuildMetabolicModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string


=end text

=item Description

Build a genome-scale metabolic model based on annotations in an input genome typed object

=back

=cut

 sub build_metabolic_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function build_metabolic_model (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to build_metabolic_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'build_metabolic_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.build_metabolic_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'build_metabolic_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method build_metabolic_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'build_metabolic_model',
				       );
    }
}
 


=head2 gapfill_metabolic_model

  $results = $obj->gapfill_metabolic_model($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.GapfillMetabolicModelParams
$results is a fba_tools.GapfillMetabolicModelResults
GapfillMetabolicModelParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	target_reaction has a value which is a fba_tools.reaction_id
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	source_fbamodel_id has a value which is a fba_tools.fbamodel_id
	source_fbamodel_workspace has a value which is a fba_tools.workspace_name
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
fbamodel_id is a string
workspace_name is a string
media_id is a string
reaction_id is a string
bool is an int
feature_id is a string
compound_id is a string
expseries_id is a string
GapfillMetabolicModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.GapfillMetabolicModelParams
$results is a fba_tools.GapfillMetabolicModelResults
GapfillMetabolicModelParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	target_reaction has a value which is a fba_tools.reaction_id
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	source_fbamodel_id has a value which is a fba_tools.fbamodel_id
	source_fbamodel_workspace has a value which is a fba_tools.workspace_name
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
fbamodel_id is a string
workspace_name is a string
media_id is a string
reaction_id is a string
bool is an int
feature_id is a string
compound_id is a string
expseries_id is a string
GapfillMetabolicModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string


=end text

=item Description

Gapfills a metabolic model to induce flux in a specified reaction

=back

=cut

 sub gapfill_metabolic_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function gapfill_metabolic_model (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to gapfill_metabolic_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'gapfill_metabolic_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.gapfill_metabolic_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'gapfill_metabolic_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method gapfill_metabolic_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'gapfill_metabolic_model',
				       );
    }
}
 


=head2 run_flux_balance_analysis

  $results = $obj->run_flux_balance_analysis($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.RunFluxBalanceAnalysisParams
$results is a fba_tools.RunFluxBalanceAnalysisResults
RunFluxBalanceAnalysisParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	target_reaction has a value which is a fba_tools.reaction_id
	fba_output_id has a value which is a fba_tools.fba_id
	workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	fva has a value which is a fba_tools.bool
	minimize_flux has a value which is a fba_tools.bool
	simulate_ko has a value which is a fba_tools.bool
	find_min_media has a value which is a fba_tools.bool
	all_reversible has a value which is a fba_tools.bool
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	max_c_uptake has a value which is a float
	max_n_uptake has a value which is a float
	max_p_uptake has a value which is a float
	max_s_uptake has a value which is a float
	max_o_uptake has a value which is a float
	default_max_uptake has a value which is a float
	notes has a value which is a string
	massbalance has a value which is a string
fbamodel_id is a string
workspace_name is a string
media_id is a string
reaction_id is a string
fba_id is a string
bool is an int
feature_id is a string
compound_id is a string
expseries_id is a string
RunFluxBalanceAnalysisResults is a reference to a hash where the following keys are defined:
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	objective has a value which is an int
ws_fba_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.RunFluxBalanceAnalysisParams
$results is a fba_tools.RunFluxBalanceAnalysisResults
RunFluxBalanceAnalysisParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	target_reaction has a value which is a fba_tools.reaction_id
	fba_output_id has a value which is a fba_tools.fba_id
	workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	fva has a value which is a fba_tools.bool
	minimize_flux has a value which is a fba_tools.bool
	simulate_ko has a value which is a fba_tools.bool
	find_min_media has a value which is a fba_tools.bool
	all_reversible has a value which is a fba_tools.bool
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	max_c_uptake has a value which is a float
	max_n_uptake has a value which is a float
	max_p_uptake has a value which is a float
	max_s_uptake has a value which is a float
	max_o_uptake has a value which is a float
	default_max_uptake has a value which is a float
	notes has a value which is a string
	massbalance has a value which is a string
fbamodel_id is a string
workspace_name is a string
media_id is a string
reaction_id is a string
fba_id is a string
bool is an int
feature_id is a string
compound_id is a string
expseries_id is a string
RunFluxBalanceAnalysisResults is a reference to a hash where the following keys are defined:
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	objective has a value which is an int
ws_fba_id is a string


=end text

=item Description

Run flux balance analysis and return ID of FBA object with results

=back

=cut

 sub run_flux_balance_analysis
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function run_flux_balance_analysis (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to run_flux_balance_analysis:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'run_flux_balance_analysis');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.run_flux_balance_analysis",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'run_flux_balance_analysis',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method run_flux_balance_analysis",
					    status_line => $self->{client}->status_line,
					    method_name => 'run_flux_balance_analysis',
				       );
    }
}
 


=head2 compare_fba_solutions

  $results = $obj->compare_fba_solutions($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.CompareFBASolutionsParams
$results is a fba_tools.CompareFBASolutionsResults
CompareFBASolutionsParams is a reference to a hash where the following keys are defined:
	fba_id_list has a value which is a reference to a list where each element is a fba_tools.fba_id
	fba_workspace has a value which is a fba_tools.workspace_name
	fbacomparison_output_id has a value which is a fba_tools.fbacomparison_id
	workspace has a value which is a fba_tools.workspace_name
fba_id is a string
workspace_name is a string
fbacomparison_id is a string
CompareFBASolutionsResults is a reference to a hash where the following keys are defined:
	new_fbacomparison_ref has a value which is a fba_tools.ws_fbacomparison_id
ws_fbacomparison_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.CompareFBASolutionsParams
$results is a fba_tools.CompareFBASolutionsResults
CompareFBASolutionsParams is a reference to a hash where the following keys are defined:
	fba_id_list has a value which is a reference to a list where each element is a fba_tools.fba_id
	fba_workspace has a value which is a fba_tools.workspace_name
	fbacomparison_output_id has a value which is a fba_tools.fbacomparison_id
	workspace has a value which is a fba_tools.workspace_name
fba_id is a string
workspace_name is a string
fbacomparison_id is a string
CompareFBASolutionsResults is a reference to a hash where the following keys are defined:
	new_fbacomparison_ref has a value which is a fba_tools.ws_fbacomparison_id
ws_fbacomparison_id is a string


=end text

=item Description

Compares multiple FBA solutions and saves comparison as a new object in the workspace

=back

=cut

 sub compare_fba_solutions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_fba_solutions (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_fba_solutions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_fba_solutions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.compare_fba_solutions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_fba_solutions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_fba_solutions",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_fba_solutions',
				       );
    }
}
 


=head2 propagate_model_to_new_genome

  $results = $obj->propagate_model_to_new_genome($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.PropagateModelToNewGenomeParams
$results is a fba_tools.PropagateModelToNewGenomeResults
PropagateModelToNewGenomeParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	proteincomparison_id has a value which is a fba_tools.proteincomparison_id
	proteincomparison_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	keep_nogene_rxn has a value which is a fba_tools.bool
	gapfill_model has a value which is a fba_tools.bool
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
fbamodel_id is a string
workspace_name is a string
proteincomparison_id is a string
bool is an int
media_id is a string
compound_id is a string
expseries_id is a string
PropagateModelToNewGenomeResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.PropagateModelToNewGenomeParams
$results is a fba_tools.PropagateModelToNewGenomeResults
PropagateModelToNewGenomeParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	proteincomparison_id has a value which is a fba_tools.proteincomparison_id
	proteincomparison_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	keep_nogene_rxn has a value which is a fba_tools.bool
	gapfill_model has a value which is a fba_tools.bool
	media_id has a value which is a fba_tools.media_id
	media_workspace has a value which is a fba_tools.workspace_name
	thermodynamic_constraints has a value which is a fba_tools.bool
	comprehensive_gapfill has a value which is a fba_tools.bool
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	exp_threshold_margin has a value which is a float
	activation_coefficient has a value which is a float
	omega has a value which is a float
	objective_fraction has a value which is a float
	minimum_target_flux has a value which is a float
	number_of_solutions has a value which is an int
fbamodel_id is a string
workspace_name is a string
proteincomparison_id is a string
bool is an int
media_id is a string
compound_id is a string
expseries_id is a string
PropagateModelToNewGenomeResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
	new_fba_ref has a value which is a fba_tools.ws_fba_id
	number_gapfilled_reactions has a value which is an int
	number_removed_biomass_compounds has a value which is an int
ws_fbamodel_id is a string
ws_fba_id is a string


=end text

=item Description

Translate the metabolic model of one organism to another, using a mapping of similar proteins between their genomes

=back

=cut

 sub propagate_model_to_new_genome
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function propagate_model_to_new_genome (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to propagate_model_to_new_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'propagate_model_to_new_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.propagate_model_to_new_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'propagate_model_to_new_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method propagate_model_to_new_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'propagate_model_to_new_genome',
				       );
    }
}
 


=head2 simulate_growth_on_phenotype_data

  $results = $obj->simulate_growth_on_phenotype_data($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.SimulateGrowthOnPhenotypeDataParams
$results is a fba_tools.SimulateGrowthOnPhenotypeDataResults
SimulateGrowthOnPhenotypeDataParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	phenotypeset_id has a value which is a fba_tools.phenotypeset_id
	phenotypeset_workspace has a value which is a fba_tools.workspace_name
	phenotypesim_output_id has a value which is a fba_tools.phenotypesim_id
	workspace has a value which is a fba_tools.workspace_name
	all_reversible has a value which is a fba_tools.bool
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
fbamodel_id is a string
workspace_name is a string
phenotypeset_id is a string
phenotypesim_id is a string
bool is an int
feature_id is a string
reaction_id is a string
compound_id is a string
SimulateGrowthOnPhenotypeDataResults is a reference to a hash where the following keys are defined:
	new_phenotypesim_ref has a value which is a fba_tools.ws_phenotypesim_id
ws_phenotypesim_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.SimulateGrowthOnPhenotypeDataParams
$results is a fba_tools.SimulateGrowthOnPhenotypeDataResults
SimulateGrowthOnPhenotypeDataParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	phenotypeset_id has a value which is a fba_tools.phenotypeset_id
	phenotypeset_workspace has a value which is a fba_tools.workspace_name
	phenotypesim_output_id has a value which is a fba_tools.phenotypesim_id
	workspace has a value which is a fba_tools.workspace_name
	all_reversible has a value which is a fba_tools.bool
	feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
	reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
	custom_bound_list has a value which is a reference to a list where each element is a string
	media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
fbamodel_id is a string
workspace_name is a string
phenotypeset_id is a string
phenotypesim_id is a string
bool is an int
feature_id is a string
reaction_id is a string
compound_id is a string
SimulateGrowthOnPhenotypeDataResults is a reference to a hash where the following keys are defined:
	new_phenotypesim_ref has a value which is a fba_tools.ws_phenotypesim_id
ws_phenotypesim_id is a string


=end text

=item Description

Use Flux Balance Analysis (FBA) to simulate multiple growth phenotypes.

=back

=cut

 sub simulate_growth_on_phenotype_data
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function simulate_growth_on_phenotype_data (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to simulate_growth_on_phenotype_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'simulate_growth_on_phenotype_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.simulate_growth_on_phenotype_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'simulate_growth_on_phenotype_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method simulate_growth_on_phenotype_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'simulate_growth_on_phenotype_data',
				       );
    }
}
 


=head2 merge_metabolic_models_into_community_model

  $results = $obj->merge_metabolic_models_into_community_model($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.MergeMetabolicModelsIntoCommunityModelParams
$results is a fba_tools.MergeMetabolicModelsIntoCommunityModelResults
MergeMetabolicModelsIntoCommunityModelParams is a reference to a hash where the following keys are defined:
	fbamodel_id_list has a value which is a reference to a list where each element is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	mixed_bag_model has a value which is a fba_tools.bool
fbamodel_id is a string
workspace_name is a string
bool is an int
MergeMetabolicModelsIntoCommunityModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
ws_fbamodel_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.MergeMetabolicModelsIntoCommunityModelParams
$results is a fba_tools.MergeMetabolicModelsIntoCommunityModelResults
MergeMetabolicModelsIntoCommunityModelParams is a reference to a hash where the following keys are defined:
	fbamodel_id_list has a value which is a reference to a list where each element is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	fbamodel_output_id has a value which is a fba_tools.fbamodel_id
	workspace has a value which is a fba_tools.workspace_name
	mixed_bag_model has a value which is a fba_tools.bool
fbamodel_id is a string
workspace_name is a string
bool is an int
MergeMetabolicModelsIntoCommunityModelResults is a reference to a hash where the following keys are defined:
	new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
ws_fbamodel_id is a string


=end text

=item Description

Merge two or more metabolic models into a compartmentalized community model

=back

=cut

 sub merge_metabolic_models_into_community_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function merge_metabolic_models_into_community_model (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to merge_metabolic_models_into_community_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'merge_metabolic_models_into_community_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.merge_metabolic_models_into_community_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'merge_metabolic_models_into_community_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method merge_metabolic_models_into_community_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'merge_metabolic_models_into_community_model',
				       );
    }
}
 


=head2 compare_flux_with_expression

  $results = $obj->compare_flux_with_expression($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.CompareFluxWithExpressionParams
$results is a fba_tools.CompareFluxWithExpressionResults
CompareFluxWithExpressionParams is a reference to a hash where the following keys are defined:
	fba_id has a value which is a fba_tools.fba_id
	fba_workspace has a value which is a fba_tools.workspace_name
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	estimate_threshold has a value which is a fba_tools.bool
	maximize_agreement has a value which is a fba_tools.bool
	fbapathwayanalysis_output_id has a value which is a fba_tools.fbapathwayanalysis_id
	workspace has a value which is a fba_tools.workspace_name
fba_id is a string
workspace_name is a string
expseries_id is a string
bool is an int
fbapathwayanalysis_id is a string
CompareFluxWithExpressionResults is a reference to a hash where the following keys are defined:
	new_fbapathwayanalysis_ref has a value which is a fba_tools.ws_fbapathwayanalysis_id
ws_fbapathwayanalysis_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.CompareFluxWithExpressionParams
$results is a fba_tools.CompareFluxWithExpressionResults
CompareFluxWithExpressionParams is a reference to a hash where the following keys are defined:
	fba_id has a value which is a fba_tools.fba_id
	fba_workspace has a value which is a fba_tools.workspace_name
	expseries_id has a value which is a fba_tools.expseries_id
	expseries_workspace has a value which is a fba_tools.workspace_name
	expression_condition has a value which is a string
	exp_threshold_percentile has a value which is a float
	estimate_threshold has a value which is a fba_tools.bool
	maximize_agreement has a value which is a fba_tools.bool
	fbapathwayanalysis_output_id has a value which is a fba_tools.fbapathwayanalysis_id
	workspace has a value which is a fba_tools.workspace_name
fba_id is a string
workspace_name is a string
expseries_id is a string
bool is an int
fbapathwayanalysis_id is a string
CompareFluxWithExpressionResults is a reference to a hash where the following keys are defined:
	new_fbapathwayanalysis_ref has a value which is a fba_tools.ws_fbapathwayanalysis_id
ws_fbapathwayanalysis_id is a string


=end text

=item Description

Merge two or more metabolic models into a compartmentalized community model

=back

=cut

 sub compare_flux_with_expression
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_flux_with_expression (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_flux_with_expression:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_flux_with_expression');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.compare_flux_with_expression",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_flux_with_expression',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_flux_with_expression",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_flux_with_expression',
				       );
    }
}
 


=head2 check_model_mass_balance

  $results = $obj->check_model_mass_balance($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a fba_tools.CheckModelMassBalanceParams
$results is a fba_tools.CheckModelMassBalanceResults
CheckModelMassBalanceParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	workspace has a value which is a fba_tools.workspace_name
fbamodel_id is a string
workspace_name is a string
CheckModelMassBalanceResults is a reference to a hash where the following keys are defined:
	new_report_ref has a value which is a fba_tools.ws_report_id
ws_report_id is a string

</pre>

=end html

=begin text

$params is a fba_tools.CheckModelMassBalanceParams
$results is a fba_tools.CheckModelMassBalanceResults
CheckModelMassBalanceParams is a reference to a hash where the following keys are defined:
	fbamodel_id has a value which is a fba_tools.fbamodel_id
	fbamodel_workspace has a value which is a fba_tools.workspace_name
	workspace has a value which is a fba_tools.workspace_name
fbamodel_id is a string
workspace_name is a string
CheckModelMassBalanceResults is a reference to a hash where the following keys are defined:
	new_report_ref has a value which is a fba_tools.ws_report_id
ws_report_id is a string


=end text

=item Description

Identifies reactions in the model that are not mass balanced

=back

=cut

 sub check_model_mass_balance
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function check_model_mass_balance (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to check_model_mass_balance:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'check_model_mass_balance');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "fba_tools.check_model_mass_balance",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'check_model_mass_balance',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method check_model_mass_balance",
					    status_line => $self->{client}->status_line,
					    method_name => 'check_model_mass_balance',
				       );
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "fba_tools.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'check_model_mass_balance',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method check_model_mass_balance",
            status_line => $self->{client}->status_line,
            method_name => 'check_model_mass_balance',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for fba_tools::fba_toolsClient\n";
    }
    if ($sMajor == 0) {
        warn "fba_tools::fba_toolsClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

A binary boolean


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 genome_id

=over 4



=item Description

A string representing a Genome id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 media_id

=over 4



=item Description

A string representing a Media id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 template_id

=over 4



=item Description

A string representing a NewModelTemplate id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fbamodel_id

=over 4



=item Description

A string representing a FBAModel id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 proteincomparison_id

=over 4



=item Description

A string representing a protein comparison id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fba_id

=over 4



=item Description

A string representing a FBA id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fbapathwayanalysis_id

=over 4



=item Description

A string representing a FBAPathwayAnalysis id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fbacomparison_id

=over 4



=item Description

A string representing a FBA comparison id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 phenotypeset_id

=over 4



=item Description

A string representing a phenotype set id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 phenotypesim_id

=over 4



=item Description

A string representing a phenotype simulation id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 expseries_id

=over 4



=item Description

A string representing an expression matrix id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reaction_id

=over 4



=item Description

A string representing a reaction id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Description

A string representing a feature id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 compound_id

=over 4



=item Description

A string representing a compound id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 workspace_name

=over 4



=item Description

A string representing a workspace name.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_fbamodel_id

=over 4



=item Description

The workspace ID for a FBAModel data object.
@id ws KBaseFBA.FBAModel


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_fba_id

=over 4



=item Description

The workspace ID for a FBA data object.
@id ws KBaseFBA.FBA


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_fbacomparison_id

=over 4



=item Description

The workspace ID for a FBA data object.
@id ws KBaseFBA.FBA


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_phenotypesim_id

=over 4



=item Description

The workspace ID for a phenotype set simulation object.
@id ws KBasePhenotypes.PhenotypeSimulationSet


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_fbapathwayanalysis_id

=over 4



=item Description

The workspace ID for a FBA pathway analysis object
@id ws KBaseFBA.FBAPathwayAnalysis


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ws_report_id

=over 4



=item Description

The workspace ID for a Report object
@id ws KBaseReport.Report


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 BuildMetabolicModelParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_id has a value which is a fba_tools.genome_id
genome_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
template_id has a value which is a fba_tools.template_id
template_workspace has a value which is a fba_tools.workspace_name
coremodel has a value which is a fba_tools.bool
gapfill_model has a value which is a fba_tools.bool
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_id has a value which is a fba_tools.genome_id
genome_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
template_id has a value which is a fba_tools.template_id
template_workspace has a value which is a fba_tools.workspace_name
coremodel has a value which is a fba_tools.bool
gapfill_model has a value which is a fba_tools.bool
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int


=end text

=back



=head2 BuildMetabolicModelResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int


=end text

=back



=head2 GapfillMetabolicModelParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
target_reaction has a value which is a fba_tools.reaction_id
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
source_fbamodel_id has a value which is a fba_tools.fbamodel_id
source_fbamodel_workspace has a value which is a fba_tools.workspace_name
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
target_reaction has a value which is a fba_tools.reaction_id
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
source_fbamodel_id has a value which is a fba_tools.fbamodel_id
source_fbamodel_workspace has a value which is a fba_tools.workspace_name
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int


=end text

=back



=head2 GapfillMetabolicModelResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int


=end text

=back



=head2 RunFluxBalanceAnalysisParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
target_reaction has a value which is a fba_tools.reaction_id
fba_output_id has a value which is a fba_tools.fba_id
workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
fva has a value which is a fba_tools.bool
minimize_flux has a value which is a fba_tools.bool
simulate_ko has a value which is a fba_tools.bool
find_min_media has a value which is a fba_tools.bool
all_reversible has a value which is a fba_tools.bool
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
max_c_uptake has a value which is a float
max_n_uptake has a value which is a float
max_p_uptake has a value which is a float
max_s_uptake has a value which is a float
max_o_uptake has a value which is a float
default_max_uptake has a value which is a float
notes has a value which is a string
massbalance has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
target_reaction has a value which is a fba_tools.reaction_id
fba_output_id has a value which is a fba_tools.fba_id
workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
fva has a value which is a fba_tools.bool
minimize_flux has a value which is a fba_tools.bool
simulate_ko has a value which is a fba_tools.bool
find_min_media has a value which is a fba_tools.bool
all_reversible has a value which is a fba_tools.bool
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
max_c_uptake has a value which is a float
max_n_uptake has a value which is a float
max_p_uptake has a value which is a float
max_s_uptake has a value which is a float
max_o_uptake has a value which is a float
default_max_uptake has a value which is a float
notes has a value which is a string
massbalance has a value which is a string


=end text

=back



=head2 RunFluxBalanceAnalysisResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fba_ref has a value which is a fba_tools.ws_fba_id
objective has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fba_ref has a value which is a fba_tools.ws_fba_id
objective has a value which is an int


=end text

=back



=head2 CompareFBASolutionsParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fba_id_list has a value which is a reference to a list where each element is a fba_tools.fba_id
fba_workspace has a value which is a fba_tools.workspace_name
fbacomparison_output_id has a value which is a fba_tools.fbacomparison_id
workspace has a value which is a fba_tools.workspace_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fba_id_list has a value which is a reference to a list where each element is a fba_tools.fba_id
fba_workspace has a value which is a fba_tools.workspace_name
fbacomparison_output_id has a value which is a fba_tools.fbacomparison_id
workspace has a value which is a fba_tools.workspace_name


=end text

=back



=head2 CompareFBASolutionsResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbacomparison_ref has a value which is a fba_tools.ws_fbacomparison_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbacomparison_ref has a value which is a fba_tools.ws_fbacomparison_id


=end text

=back



=head2 PropagateModelToNewGenomeParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
proteincomparison_id has a value which is a fba_tools.proteincomparison_id
proteincomparison_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
keep_nogene_rxn has a value which is a fba_tools.bool
gapfill_model has a value which is a fba_tools.bool
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
proteincomparison_id has a value which is a fba_tools.proteincomparison_id
proteincomparison_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
keep_nogene_rxn has a value which is a fba_tools.bool
gapfill_model has a value which is a fba_tools.bool
media_id has a value which is a fba_tools.media_id
media_workspace has a value which is a fba_tools.workspace_name
thermodynamic_constraints has a value which is a fba_tools.bool
comprehensive_gapfill has a value which is a fba_tools.bool
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
exp_threshold_margin has a value which is a float
activation_coefficient has a value which is a float
omega has a value which is a float
objective_fraction has a value which is a float
minimum_target_flux has a value which is a float
number_of_solutions has a value which is an int


=end text

=back



=head2 PropagateModelToNewGenomeResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id
new_fba_ref has a value which is a fba_tools.ws_fba_id
number_gapfilled_reactions has a value which is an int
number_removed_biomass_compounds has a value which is an int


=end text

=back



=head2 SimulateGrowthOnPhenotypeDataParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
phenotypeset_id has a value which is a fba_tools.phenotypeset_id
phenotypeset_workspace has a value which is a fba_tools.workspace_name
phenotypesim_output_id has a value which is a fba_tools.phenotypesim_id
workspace has a value which is a fba_tools.workspace_name
all_reversible has a value which is a fba_tools.bool
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
phenotypeset_id has a value which is a fba_tools.phenotypeset_id
phenotypeset_workspace has a value which is a fba_tools.workspace_name
phenotypesim_output_id has a value which is a fba_tools.phenotypesim_id
workspace has a value which is a fba_tools.workspace_name
all_reversible has a value which is a fba_tools.bool
feature_ko_list has a value which is a reference to a list where each element is a fba_tools.feature_id
reaction_ko_list has a value which is a reference to a list where each element is a fba_tools.reaction_id
custom_bound_list has a value which is a reference to a list where each element is a string
media_supplement_list has a value which is a reference to a list where each element is a fba_tools.compound_id


=end text

=back



=head2 SimulateGrowthOnPhenotypeDataResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_phenotypesim_ref has a value which is a fba_tools.ws_phenotypesim_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_phenotypesim_ref has a value which is a fba_tools.ws_phenotypesim_id


=end text

=back



=head2 MergeMetabolicModelsIntoCommunityModelParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id_list has a value which is a reference to a list where each element is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
mixed_bag_model has a value which is a fba_tools.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id_list has a value which is a reference to a list where each element is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
fbamodel_output_id has a value which is a fba_tools.fbamodel_id
workspace has a value which is a fba_tools.workspace_name
mixed_bag_model has a value which is a fba_tools.bool


=end text

=back



=head2 MergeMetabolicModelsIntoCommunityModelResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbamodel_ref has a value which is a fba_tools.ws_fbamodel_id


=end text

=back



=head2 CompareFluxWithExpressionParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fba_id has a value which is a fba_tools.fba_id
fba_workspace has a value which is a fba_tools.workspace_name
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
estimate_threshold has a value which is a fba_tools.bool
maximize_agreement has a value which is a fba_tools.bool
fbapathwayanalysis_output_id has a value which is a fba_tools.fbapathwayanalysis_id
workspace has a value which is a fba_tools.workspace_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fba_id has a value which is a fba_tools.fba_id
fba_workspace has a value which is a fba_tools.workspace_name
expseries_id has a value which is a fba_tools.expseries_id
expseries_workspace has a value which is a fba_tools.workspace_name
expression_condition has a value which is a string
exp_threshold_percentile has a value which is a float
estimate_threshold has a value which is a fba_tools.bool
maximize_agreement has a value which is a fba_tools.bool
fbapathwayanalysis_output_id has a value which is a fba_tools.fbapathwayanalysis_id
workspace has a value which is a fba_tools.workspace_name


=end text

=back



=head2 CompareFluxWithExpressionResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_fbapathwayanalysis_ref has a value which is a fba_tools.ws_fbapathwayanalysis_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_fbapathwayanalysis_ref has a value which is a fba_tools.ws_fbapathwayanalysis_id


=end text

=back



=head2 CheckModelMassBalanceParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
workspace has a value which is a fba_tools.workspace_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fbamodel_id has a value which is a fba_tools.fbamodel_id
fbamodel_workspace has a value which is a fba_tools.workspace_name
workspace has a value which is a fba_tools.workspace_name


=end text

=back



=head2 CheckModelMassBalanceResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_report_ref has a value which is a fba_tools.ws_report_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_report_ref has a value which is a fba_tools.ws_report_id


=end text

=back



=cut

package fba_tools::fba_toolsClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
