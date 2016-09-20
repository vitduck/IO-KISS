package IO::KISS; 

use strict; 
use warnings FATAL => 'all'; 

use Moose; 
use MooseX::Types; 
use MooseX::Types::Moose qw( Undef Str Ref ArrayRef GlobRef ); 

use namespace::autoclean; 
use feature  qw( switch ); 
use experimental qw( signatures smartmatch ); 

has 'stream', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    required  => 1, 
); 

has 'mode', ( 
    is        => 'ro', 
    isa       => enum( [ qw( r w a ) ] ),   
    required  => 1, 
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef,
    builder   => 'open', 
); 

has 'separator', ( 
    is        => 'ro', 
    isa       => Str | Undef, 
    lazy      => 1, 
    init_arg  => undef, 
    writer    => '_set_separator', 
    default   => "\n", 
); 

has 'slurp_mode', ( 
    is        => 'ro', 
    isa       => Str,  
    lazy      => 1, 
    init_arg  => undef, 
    reader    => 'slurp',  
    builder   => '_build_slurp'
); 

has 'line_mode', ( 
    is        => 'ro', 
    isa       => ArrayRef[ Str ],  
    traits    => [ 'Array' ],
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_line', 
    handles   => { 
        get_line  => 'shift', 
        get_lines => 'elements' 
    },  
); 

has 'paragraph_mode', ( 
    is        => 'ro', 
    isa       => ArrayRef[ Str ],  
    traits    => [ 'Array' ],
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_paragraph', 
    handles   => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements' }, 
); 

override BUILDARGS => sub ( $class, @args ) { 
    return @args == 2  ? { stream => $args[0], mode => $args[1] } : super; 
}; 

sub open ( $self ) { 
    use autodie qw( open ); 
    my $fh; 

    given ( $self->mode ) { 
        when ( 'r' ) { open $fh, '<' , $self->stream } 
        when ( 'w' ) { open $fh, '>' , $self->stream } 
        when ( 'a' ) { open $fh, '>>', $self->stream }
    }

    return $fh; 
} 

sub close ( $self ) { 
    use autodie qw( close ); 
    close $self->fh; 
} 

sub read_fh ( $self ) { 
    # list context
    chomp ( 
        my @lines  = do { 
            local $/ = $self->separator; 
            readline $self->fh;  
        }   
    ); 
    
    $self->close; 

    # line | paragraph -> arrayref
    return defined $self->separator ? \@lines : shift @lines 
} 

sub print ( $self, @items ) { 
    print { $self->fh } "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf { $self->fh } $format, @items; 
}

sub _build_slurp ( $self ) { 
    return do {         
        $self->_set_separator( undef ); 
        $self->read_fh 
    }
}

sub _build_line ( $self ) { 
    return $self->read_fh 
} 

sub _build_paragraph ( $self ) { 
    return do {         
        $self->_set_separator( '' ); 
        $self->read_fh 
    }
} 

__PACKAGE__->meta->make_immutable;

1 
