# netcdf

A Ruby interface to the NetCDF library. It is built on the
[NMatrix](https://github.com/SciRuby/nmatrix#readme) library and
uses [Ruby-FFI](https://github.com/ffi/ffi#readme).

The NMatrix library provides an efficient N-dimensional array, like the NumPy
array. It is part of the SciRuby project.

Ruby-FFI is a ruby extension for loading dynamic libraries, binding functions,
and calling those functions from Ruby code. A Ruby-FFI extension works without
changes on Ruby and JRuby.


## What is the NetCDF?

The NetCDF is a binary file format used to store data in machine-independent
way. A NetCDF file contains metadata, which can be units and description of data
for example, that make the data self-describing.

It is very convenient to store spatialized data (like geographic data, maps can
be displayed with an external tool like Panoply), thus it is widely used in
climatology, meteorology and oceanography applications.

The NetCDF is designed to store array-oriented data and allows subsets access in
an efficient way. The library is written in C, but official APIs are available
for C++, Fortran (one for Fortran 77 and one for Fortran 90) and Java
(independant implementation, not based on the C library). Third-party APIs are
provided and maintened by the community for other langages like R, Python, Ruby,
Perl, ...
Moreover, a wide range of utilities, from command-line tools to graphical
softwares, are available to process, analyse and visualize NetCDF files.

More information about NetCDF can be found on the
[Wikipedia Page](https://en.wikipedia.org/wiki/Netcdf).

## Why a new Ruby library for NetCDF ?

A Ruby API for the NetCDF library already exists:
[RubyNetCDF](http://ruby.gfd-dennou.org/products/ruby-netcdf/), by T. Horinouchi
and _al_. So why this project?

For two reasons, I am not happy with the existing library. These reasons
are:
1. lack of features: the API provided is quite old, there is no support for the
   NetCDF-4 format.
2. NArray-based: because of that, it uses a column-major indexing (like Fortran)
   which is not convenient as Ruby usually uses row-major indexing (like C).

For these reasons, I decided to craft my own wrapper around the NetCDF C
library. To address the indexing issue, I decided to use NMatrix from the
SciRuby project.


## Install

    $ gem build netcdf.gemspec
    $ gem install netcdf-X.Y.Z.gem


## Testing

To run the tests:

    $ rake


## Examples

Examples are available in the example directory.

## License

This software is licensed under the BSD3 license.

© 2013-2014 Sylvain Laperche <sylvain.laperche@gmail.com>.
