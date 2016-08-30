package IO::KISS; 

# cpan
use Moose; 
use MooseX::Types; 
use namespace::autoclean; 

# pragma
use autodie; 
use warnings FATAL => 'all'; 
use feature qw/switch/; 
use experimental qw/signatures smartmatch/; 

# Moose attributes 
has 'file', ( 
    is        => 'rw', 
    isa       => 'Str', 
    required  => 1, 
); 

# read | write | append 
has 'mode', ( 
    is        => 'ro', 
    isa       => enum([ qw/r w a/ ]),   
    required  => 1, 
); 

has 'fh', ( 
    is        => 'ro', 
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        my $fh; 
        given ( $self->mode ) { 
            when ( 'r' ) { open $fh, '<' , ( -f $self->file ? $self->file : \$self->file ) } 
            when ( 'w' ) { open $fh, '>' , $self->file } 
            when ( 'a' ) { open $fh, '>>', $self->file } 
        }
        return $fh; 
    }, 
); 

has '_separator', ( 
    is        => 'rw', 
    init_arg  => 'undef', 
    default   => "\n", 
); 

# slurp mode 
has 'slurp', ( 
    is        => 'ro', 
    isa       => 'Str', 
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        $self->_separator(undef); 
        return $self->readline;  
    }
); 

# line mode 
has 'line', ( 
    is        => 'ro', 
    isa       => 'ArrayRef[Str]',  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        return $self->readline; 
    },  
    handles   => { 
        get_line  => 'shift', 
        get_lines => 'elements', 
    }, 
); 

# paragraph mode 
has 'paragraph', ( 
    is        => 'ro', 
    isa       => 'ArrayRef[Str]',  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        $self->_separator(''); 
        return $self->readline;  
    }, 
    handles   => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements', 
    }, 
); 

# Moose methods 
# Error: Prototype mismatch: sub IO::KISS::eead (*\$$;$) vs none
sub readline ( $self ) { 
    chomp ( my @lines  = do { local $/ = $self->_separator; readline $self->fh } ); 
    return defined $self->_separator ? \@lines : shift @lines; 
} 

sub print ( $self, @items ) { 
    print {$self->fh} "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf {$self->fh} $format, @items; 
}

sub BUILD ( $self, @args ) { 
    chomp ( my $removed_newline = $self->file );  
    $self->file($removed_newline); 
} 

# simple constructors 
override BUILDARGS => sub ( $class, @args ) { 
    return @args == 2  ? { file => $args[0], mode => $args[1] } : super; 
}; 

# speed-up object construction 
__PACKAGE__->meta->make_immutable;

1; 
