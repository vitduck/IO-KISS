package IO::Reader; 

use Moose::Role; 
use MooseX::Types::Moose qw/Str HashRef/; 
use IO::KISS; 

use namespace::autoclean; 
use experimental 'signatures';  

has 'input', ( 
    is       => 'ro', 
    isa      => Str,  
    reader   => 'get_input'
); 

has 'reader', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_reader', 
    clearer   => 'clear_reader', 
    handles   => [ qw/chomp slurp get_line get_lines get_paragraph get_paragraphs/ ] 
); 

sub _build_reader ( $self ) {
    return IO::KISS->new( $self->get_input, 'r' ) 
} 

1 
