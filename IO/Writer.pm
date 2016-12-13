package IO::Writer; 

use Moose::Role; 
use MooseX::Types::Moose 'Str'; 
use IO::KISS; 

use namespace::autoclean; 
use experimental 'signatures';  

has 'output', ( 
    is       => 'ro', 
    isa      => Str,  
    reader   => 'get_output'
); 

has 'o_mode', ( 
    is       => 'ro', 
    isa      => Str, 
    init_arg => undef, 
    lazy     => 1, 
    reader   => 'get_o_mode',
    default  => 'w' 
); 

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    init_arg  => undef, 
    lazy      => 1, 
    builder   => '_build_writer', 
    clearer   => 'clear_writer', 
    handles   => [ qw/print printf/ ]
); 

sub _build_writer ( $self ) {
    return IO::KISS->new( $self->get_output, $self->get_o_mode ) 
} 

1 
