#encoding: utf-8

# A Ruby interface to the NetCDF library.
# It is built on the NMatrix library and uses Ruby FFI.
module NetCDF
  # An array containing the version number.
  # The numbers in the array are the major, minor, and patch versions,
  # respectively.
  VERSION = [0, 1, 0]

  require 'netcdf/netcdf'
end
