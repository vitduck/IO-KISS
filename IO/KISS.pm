package IO::KISS; 

# cpan
use Moose; 
use MooseX::Types; 
use namespace::autoclean; 

# pragma
use autodie; 
use warnings FATAL => 'all'; 
use experimental qw/signatures/; 

# Moose attributes 
has 'file', ( 
    is        => 'ro', 
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

        if    ( $self->mode eq 'r' ) { open $fh, '<' , ( -f $self->file ? $self->file : \$self->file ) }  
        elsif ( $self->mode eq 'w' ) { open $fh, '>' , $self->file  }  
        else                         { open $fh, '>>', $self->file }  

        return $fh; 
    }, 
); 

# slurp mode 
has 'slurp', ( 
    is        => 'ro', 
    isa       => 'Str', 
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        my $fh = $self->fh; 
        chomp ( my $line = do { local $/ = undef; <$fh> } );

        return $line; 
    }, 
); 

# line mode 
has 'line', ( 
    is        => 'ro', 
    isa       => 'ArrayRef[Str]',  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        my $fh   = $self->fh;  
        chomp ( my @lines = <$fh> ); 

        return \@lines; 
    },  
    
    handles => { 
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
        my $fh   = $self->fh;   
        chomp (my @paragraphs = do { local $/ = ''; <$fh> });  

        return \@paragraphs;  
    },  

    handles => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements', 
    }, 
); 

sub print ( $self, @items,  ) { 
    printf {$self->fh} "%s\n", @items; 
} 

sub printf ( $self, $format, @items ) { 
    printf {$self->fh} $format, @items; 
}

# simple constructors 
override BUILDARGS => sub ( $class, @args ) { 
    return 
        @args == 2  ? 
        { file => $args[0], mode => $args[1] } : 
        super; 
}; 

# speed-up object construction 
__PACKAGE__->meta->make_immutable;

1; 
