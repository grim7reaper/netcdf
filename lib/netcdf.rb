#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

# A Ruby interface to the NetCDF library.
# It is built on the NMatrix library and uses Ruby FFI.
module NetCDF
  # An array containing the version number.
  # The numbers in the array are the major, minor, and patch versions,
  # respectively.
  VERSION = [0, 4, 0]

  require 'netcdf/netcdf'
  require 'netcdf/dataset'
  require 'netcdf/dimension'
end
