package IO::KISS; 

use strictures 2; 
use feature qw/switch/; 

use Moose; 
use MooseX::Types; 
use MooseX::Types::Moose qw/Undef Str Ref ArrayRef GlobRef/; 

use experimental qw/signatures smartmatch/; 
use namespace::autoclean; 

# Moose attributes 
has 'stream', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    required  => 1, 
); 

# read | write | append 
has 'mode', ( 
    is        => 'ro', 
    isa       => enum([ qw( r w a ) ]),   
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
    init_arg  => 'undef', 
    default   => "\n", 
    writer    => '_set_separator', 
); 

# slurp mode 
has 'slurp', ( 
    is        => 'ro', 
    isa       => Str,  
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_slurp_mode', 
); 

# line mode 
has 'line', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_line_mode', 
    handles   => { get_line => 'shift', get_lines => 'elements' },  
); 

# paragraph mode 
has 'paragraph', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_paragraph_mode', 
    handles   => { get_paragraph => 'shift', get_paragraphs => 'elements' }, 
); 

sub open ( $self ) { 
    my $fh; 
    try { 
        use autodie qw/open/;  
        given ( $self->mode ) { 
            when ( 'r' ) { open $fh, '<' , $self->stream } 
            when ( 'w' ) { open $fh, '>' , $self->stream } 
            when ( 'a' ) { open $fh, '>>', $self->stream }
        }
    }
    return $fh; 
} 

sub close ( $self ) { 
    try { 
        use autodie qw/close/; 
        close $self->fh; 
    }
} 

sub _slurp_mode ( $self ) { 
    $self->_set_separator( undef ); 
    return $self->read; 
} 

sub _line_mode ( $self ) { 
    return $self->read
} 

sub _paragraph_mode ( $self ) { 
    $self->_set_separator( '' ); 
    return $self->read; 
} 

sub read ( $self ) { 
    # list context;
    chomp ( 
        my @lines  = do { 
            local $/ = $self->separator; 
            readline $self->fh;  
        }   
    ); 
    $self->close; 

    # slurp -> undef -> scalar 
    # line | paragraph -> arrayref
    return defined $self->separator ? \@lines : shift @lines; 
} 

sub print ( $self, @items ) { 
    print {$self->fh} "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf {$self->fh} $format, @items; 
}

override BUILDARGS => sub ( $class, @args ) { 
    return @args == 2  ? { stream => $args[0], mode => $args[1] } : super; 
}; 

__PACKAGE__->meta->make_immutable;

1; 
