package IO::RW; 

use Moose::Role; 
use MooseX::Types::Moose qw/Str HashRef/;  

use strictures 2; 
use namespace::autoclean; 
use experimental qw/signatures/;

use IO::KISS; 

requires '_parse_file'; 

has 'file', ( 
    is        => 'ro', 
    isa       => Str, 
); 

# delegate I/O to IO::KISS
has 'reader', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        return IO::KISS->new($self->file, 'r') 
    }, 

    handles   => [ 
        qw/get_string/,  
        qw/get_line get_lines/, 
        qw/get_paragraph get_paragraph/, 
    ], 
);  

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        IO::KISS->new($self->file, 'w') 
    }, 

    handles   => [ 
        qw/print printf/, 
        qw/close_fh/, 
    ],   
); 

has 'parser', ( 
    is        => 'ro', 
    isa       => HashRef, 
    traits    => ['Hash'], 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_parse_file', 

    handles   => { 
        read => 'get' 
    }, 
); 

1; 
