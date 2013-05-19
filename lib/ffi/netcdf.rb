#encoding: utf-8

require 'ffi'

# A wrapper around the libnetcdf.
module LibNetCDF
  extend FFI::Library

  ffi_lib 'netcdf'

  attach_function :nc_strerror   , [ :int ], :string
  attach_function :nc_inq_libvers, [ ]     , :string
end
