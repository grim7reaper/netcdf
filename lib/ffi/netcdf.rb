#encoding: utf-8

require 'ffi'

# A wrapper around the libnetcdf.
module LibNetCDF #:nodoc:
  extend FFI::Library

  ffi_lib 'netcdf'

  NC_NOERR = 0 # No Error.

  attach_function :nc_strerror   , [ :int ], :string
  attach_function :nc_inq_libvers, [ ]     , :string
end
