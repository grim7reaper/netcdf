#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

require 'ffi/netcdf'
require 'ffi/read_size_t'

include LibNetCDF

module NetCDF
  # A class that represent a netCDF Dataset.
  #
  # It may be used to represent a real physical dimension (like time, latitude,
  # longitude, ...) or be used to index other quantities, for example station or
  # model-run-number.
  class Dimension
    # Load an existing dimension.
    #
    # This method is not intented to be called explicitly.
    #
    # * *Args*    :
    #   - +owner+  -> NetCDF id or group ID.
    #   - +dim_id+ -> dimension ID.
    #   - +unlimited?+ -> the dimension is unlimited?
    # * *Returns* :
    #   - the dimension identified by `dimid`.
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes:
    #     - the owner is closed.
    #     - the dimension ID is invalid.
    def self.load_dimension(owner, dim_id, unlimited)
      # Retrieves the name (the array should have a size of NC_MAX_NAME+1).
      # +1 to include the null byte (Cf. doc of the C API).
      name_ptr = FFI::MemoryPointer.new(:char, NC_MAX_NAME+1)
      err = LibNetCDF.nc_inq_dimname(owner, dim_id, name_ptr)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      name = name_ptr.read_string()
      # Retrieves the size.
      size_ptr = FFI::MemoryPointer.new(:size_t)
      err = LibNetCDF.nc_inq_dimlen(owner, dim_id, size_ptr)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      size = size_ptr.read_size_t

      return Dimension.new(owner, dim_id, name, size, unlimited)
    end

    # Creates a new dimension.
    #
    # This method is not intented to be called explicitly.
    #
    # * *Args*    :
    #   - +owner+ -> NetCDF id or group ID.
    #   - +name+  -> dimension name.
    #   - +size+  -> dimension size (optional arguments).
    #                This should be a positive integer or 0 (unlimited
    #                dimension).
    #                Default size is 0 (unlimited).
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes:
    #     - the owner is closed.
    #     - the owner is not in define mode.
    #     - the dimension name is already used.
    #     - the length is negative.
    #     - the dimension is unlimited, but there is already one unlimited
    #     dimension (NetCDF-3 only)
    def self.create_dimension(owner, name, size = 0)
      if size == 0
        size = NC_UNLIMITED
        unlimited = true
      else
        size = size
        unlimited = false
      end
      # Retrieve the dimension ID.
      id_ptr = FFI::MemoryPointer.new(:int)
      err = LibNetCDF.nc_def_dim(owner, name, size, id_ptr)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      dim_id = id_ptr.read_int

      return Dimension.new(owner, dim_id, name, size, unlimited)
    end

    # Initializes a new Dimension.
    #
    # <b>Dimension must be created using the create_dim method</b> of a Group or
    # Dataset instance, not using this class directly.
    #
    # * *Args*    :
    #   - +owner+  -> NetCDF id or group ID.
    #   - +dim_id+ -> dimension ID.
    #   - +name+   -> dimension name.
    #   - +size+   -> dimension size.
    #   - +unlimited+ -> the dimension is unlimited?
    def initialize(owner, dim_id, name, size, unlimited)
      @owner = owner
      @id    = dim_id
      @name  = name
      @size  = size
      @unlimited = unlimited
    end

    # Return *true* if the dimension is unlimited, otherwise *false*.
    #
    # * *Returns* :
    #   - *true* if the dimension is unlimited, otherwise *false*.
    def unlimited?
      @unlimited
    end

    # Return the length of dimension.
    #
    # For the unlimited dimension, this is the number of records written so far.
    #
    # * *Returns* :
    #   - the length of dimension.
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes:
    #     - the dataset is closed.
    def length
      # An unlimited dimension can grow as needed, so we have to make a call to
      # the C library to be sure we return the correct current size.
      if @unlimited
        size_ptr = FFI::MemoryPointer.new(:size_t)
        err = LibNetCDF.nc_inq_dimlen(owner, @id, size_ptr)
        fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
        @size = size_ptr.read_size_t
      end
      @size
    end
    alias_method :size, :length

    attr_reader :owner
    attr_reader :id
    attr_reader :name
  end
end
