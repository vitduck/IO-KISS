package IO::KISS; 

# cpan
use Moose; 
use namespace::autoclean; 

# pragma
use autodie; 
use warnings FATAL => 'all'; 
use experimental qw/signatures/; 

# Moose attributes 
has 'file', ( 
    is       => 'ro', 
    isa      => 'Str', 
    required => 1, 
); 

has 'reader', ( 
    is       => 'ro', 
    lazy     => 1, 
    init_arg => undef, 

    default  => sub ( $self ) { 
        # fh to either a file or a string
        open my $fh, '<', ( -f $self->file ? $self->file : \$self->file ); 

        return $fh; 
    }, 
); 

has 'writer', ( 
    is       => 'ro', 
    lazy     => 1, 
    init_arg => undef, 
    
    default  => sub ( $self ) { 
        # fh to file
        open my $fh, '>', $self->file; 

        return $fh; 
    }, 
); 

# slurp mode 
has 'string', ( 
    is       => 'ro', 
    isa      => 'Str', 
    lazy     => 1, 
    init_arg => undef, 
    reader   => 'slurp', 

    default  => sub ( $self ) { 
        my $fh = $self->reader;  
        chomp ( my $line = do { local $/ = undef; <$fh> } );

        return $line; 
    }, 
); 

# line mode 
has 'line', ( 
    is       => 'ro', 
    isa      => 'ArrayRef[Str]',  
    traits  => ['Array'],
    lazy     => 1, 
    init_arg => undef, 

    default  => sub ( $self ) { 
        my $fh   = $self->reader;  
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
    is       => 'ro', 
    isa      => 'ArrayRef[Str]',  
    traits  => ['Array'],
    lazy     => 1, 
    init_arg => undef, 

    default  => sub ( $self ) { 
        my $fh   = $self->reader;  
        chomp (my @paragraphs = do { local $/ = ''; <$fh> });  

        return \@paragraphs;  
    },  

    handles => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements', 
    }, 
); 

# simple constructors 
override BUILDARGS => sub ( $class, @args ) { 
    return ( @args == 1 ? { file => $args[0] } : super ); 
}; 

# speed-up object construction 
__PACKAGE__->meta->make_immutable;

1; 
