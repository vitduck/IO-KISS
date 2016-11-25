package IO::Writer; 

use IO::KISS; 

use Moose::Role; 
use MooseX::Types::Moose 'Str'; 
use namespace::autoclean; 

use experimental 'signatures'; 

has 'output', ( 
    is       => 'ro', 
    isa      => Str,  
    lazy     => 1,
    default  => ''
); 

has 'o_mode', ( 
    is       => 'ro', 
    isa      => Str, 
    init_arg => undef, 
    lazy     => 1, 
    default  => 'w' 
); 

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    init_arg  => undef, 
    lazy      => 1, 
    builder   => '_build_writer', 
    clearer   => '_clear_writer', 
    handles   => { 
        _print        => 'print', 
        _printf       => 'printf', 
        _close_writer => 'close' 
    }
); 

sub _build_writer ( $self ) {
    return IO::KISS->new( 
        file   => $self->output, 
        mode   => $self->o_mode,   
    ) 
} 

1 
