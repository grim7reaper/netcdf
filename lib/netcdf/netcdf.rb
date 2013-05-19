#encoding: utf-8

require 'ffi/netcdf'

module NetCDF
  def self.strerror(error)
    LibNetCDF.nc_strerror(error)
  end

  def self.c_version
    LibNetCDF.nc_inq_libvers.split.first.split('.').map(&:to_i)
  end
end
