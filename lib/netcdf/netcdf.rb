#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

require 'ffi/netcdf'

include LibNetCDF

module NetCDF
  # Return the version number, as an array, of the NetCDF C library used.
  #
  # The numbers in the array are the major, minor, and patch versions,
  # respectively.
  #
  # @return [Array<Fixnum>] the version number of the NetCDF C library used.
  def self.c_version
    return nc_inq_libvers.split.first.split('.').map(&:to_i)
  end

  # An exception class to wrap the NetCDF errors.
  class NetCDFError < StandardError
  end

  private

  # Convert an error code into an error message.
  #
  # @param error [Fixnum] an error code returned from a call to a netCDF
  #                       function.
  # @return [String] an error message corresponding to the error code.
  def self.strerror(error)
    return nc_strerror(error)
  end
end
