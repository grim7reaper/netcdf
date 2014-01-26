#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

require 'ffi'

# A thin wrapper around the libnetcdf.
# @api private
module LibNetCDF
  extend FFI::Library

  ffi_lib 'netcdf'

  NC_NOERR = 0 # No Error.

  ######################################################################
  # Define the ioflags bits for nc_create and nc_open (from netcdf.h). #
  ######################################################################

  # Set read-only.
  NC_NOWRITE       = 0x0000
  # Set read-write.
  NC_WRITE         = 0x0001
  # Destroy existing file.
  NC_CLOBBER       = 0x0000
  # Don't destroy existing file.
  NC_NOCLOBBER     = 0x0004
  # Use diskless file.
  NC_DISKLESS      = 0x0008
  # Use diskless file with mmap.
  NC_MMAP          = 0x0010
  # Enforce classic model.
  NC_CLASSIC_MODEL = 0x0100
  # Use large (64-bit) file offsets.
  NC_64BIT_OFFSET  = 0x0200
  # Ignored for now, may have an usage in the future.
  NC_LOCK          = 0x0400 
  # Share updates, limit cacheing.
  NC_SHARE         = 0x0800
  # Use netCDF-4/HDF5 format.
  NC_NETCDF4       = 0x1000
  # Turn on MPI I/O.
  NC_MPIIO         = 0x2000
  # Turn on MPI POSIX I/O.
  NC_MPIPOSIX      = 0x4000
  # Use parallel-netcdf library.
  NC_PNETCDF       = 0x8000

  # size value used for an unlimited dimension.
  NC_UNLIMITED = 0
  # Max length of a name.
  NC_MAX_NAME  = 256

  # Library
  attach_function :nc_strerror   , [ :int ], :string
  attach_function :nc_inq_libvers, [ ]     , :string
  # Dataset.
  attach_function :nc_create, [ :string, :int, :pointer ], :int
  attach_function :nc_open  , [ :string, :int, :pointer ], :int
  attach_function :nc_redef , [ :int ], :int
  attach_function :nc_enddef, [ :int ], :int
  attach_function :nc_close , [ :int ], :int
  attach_function :nc_sync  , [ :int ], :int
  # Dimensions.
  attach_function :nc_inq_ndims    , [ :int, :pointer ]                  , :int
  attach_function :nc_inq_unlimdim , [ :int, :pointer ]                  , :int
  attach_function :nc_inq_unlimdims, [ :int, :pointer, :pointer ]        , :int
  attach_function :nc_def_dim      , [ :int, :string, :size_t, :pointer ], :int
  attach_function :nc_inq_dimname  , [ :int, :int   , :pointer ]         , :int
  attach_function :nc_inq_dimlen   , [ :int, :int   , :pointer ]         , :int
end
