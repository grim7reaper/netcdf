#encoding: utf-8

require 'ffi/netcdf'

include LibNetCDF

module NetCDF
  # Return the version number, as an array, of the NetCDF C library used.
  #
  # The numbers in the array are the major, minor, and patch versions,
  # respectively.
  #
  # * *Returns* :
  #   - the version number, as an array, of the NetCDF C library used.
  def self.c_version
    nc_inq_libvers.split.first.split('.').map(&:to_i)
  end

  # An exception class to wrap the NetCDF errors.
  class NetCDFError < StandardError
  end

  private

  # Convert an error code into an error message.
  #
  # * *Args*    :
  #   - +error+ -> an error code returned from a call to a netCDF function.
  # * *Returns* :
  #   - an error message corresponding to the error code.
  def self.strerror(error)
    nc_strerror(error)
  end
end
