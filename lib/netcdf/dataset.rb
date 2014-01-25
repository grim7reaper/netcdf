#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

require 'set'

require 'ffi/netcdf'
require 'ffi/read_size_t'
require 'netcdf/dimension'

include LibNetCDF

module NetCDF
  # A class that represent a netCDF Dataset.
  #
  # It is defined by a collection of dimensions, groups (for NetCDF-4),
  # variables and attributes.
  class Dataset
    # List of supported mode.
    SUPPORTED_MODE   = [ 'r', 'w', 'r+' ]
    # List of supported format.
    SUPPORTED_FORMAT = [ 'NETCDF3', 'NETCDF3_64BIT',
                         'NETCDF4', 'NETCDF4_CLASSIC' ]

    # Create a new Dataset (or open an existing one).
    #
    # * *Args*    :
    #   - +filepath+ -> NetCDF file path.
    #   - +opts+     -> optional arguments.
    #     [mode] access mode:
    #            - _r_ means read-only.
    #            - _w_ means write (a new file is created, an existing file with
    #              the same name is deleted).
    #            - _r+_ means update (opened for reading and writing).
    #
    #            Default mode is _r_.
    #     [clobber] If *true*, opening a file with mode='w' will clobber
    #               (overwrite) an existing file with the same name.
    #
    #               If *false*, a NetCDFError will be raised if a file with the
    #               same name already exists.
    #
    #               Default value is *true*.
    #     [share] shared mode.
    #
    #             Appropriate when one process may be writing the dataset and
    #             one or more other processes reading the dataset concurrently.
    #
    #             It means that dataset accesses are not buffered and caching is
    #             limited.
    #
    #             Since the buffering scheme is optimized for sequential access,
    #             programs that do not access data sequentially may see some
    #             performance improvement.
    #
    #             Default value is *false*.
    #     [format] underlying file format:
    #              - *NETCDF3* classic netCDF 3 file format. Files
    #                larger than 2 GiB can be created, with certain
    #                limitations (see {Classic Limitations}[https://www.unidata.ucar.edu/software/netcdf/docs/netcdf/Classic-Limitations.html#Classic-Limitations]).
    #              - *NETCDF3_64BIT* 64-bit offset version of the netCDF 3
    #                file format. This format still has some limits (see {64 bit
    #                Offset Limitations}[https://www.unidata.ucar.edu/software/netcdf/docs/netcdf/64-bit-Offset-Limitations.html#g_t64-bit-Offset-Limitations]),
    #                but support very large datasets.
    #              - *NETCDF4* HDF5/NetCDF-4 file format (variables and files
    #                can be any size supported by the underlying file system),
    #                using the enhanced data model (allows groups, user defined
    #                types, multiple unlimited dimensions, new atomic types,
    #                ...).
    #              - *NETCDF4_CLASSIC* HDF5/NetCDF-4 file format, but the
    #                classic data model is enforced (no new constructs from the
    #                enhanced data model). Guaranteed to work with
    #                existing netCDF software.
    #
    #              More information about each format
    #              here[https://www.unidata.ucar.edu/software/netcdf/docs/netcdf/Which-Format.html#Which-Format].
    #
    #              Default format is *NETCDF3*.
    # * *Raises* :
    #   - +ArgumentError+ -> possible causes include:
    #     - invalid mode.
    #     - invalid format.
    #   - +NetCDFError+ -> possible causes:
    #     - the NetCDF file does not exist (read-only mode or update mode).
    #     - passing a file path that includes a non-existing directory (write
    #     mode)
    #     - the NetCDF file already exists and you set clobber to *false* (write
    #     mode)
    #     - try to create a netCDF file in a directory where you don't have
    #     permission (write mode).
    def initialize(filepath, opts={})
      # Retrieve the optional arguments.
      defaults = { mode:'r', clobber:true, share:false, format: 'NETCDF3' }
      opts = defaults.merge(opts)
      @format = opts[:format]
      # Prepare the input parameters.
      cmode = opts_to_flag(opts)
      id_ptr = FFI::MemoryPointer.new(:int)
      # Open the NetCDF file.
      if opts[:mode] == 'w'
        err = nc_create(filepath, cmode, id_ptr)
        @in_define_mode = true
        @dimensions = {}
      else
        err = nc_open(filepath, cmode, id_ptr)
        @in_define_mode = false
      end
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      # Retrieve the netCDF ID.
      @id = id_ptr.read_int
      # Load NetCDF structure.
      unless opts[:mode] == 'w'
        @dimensions = load_dimensions()
      end
    end

    # Enter into the define mode.
    #
    # That means that dimensions, variables, and attributes can be added or
    # renamed and attributes can be deleted.
    #
    # For *NETCDF4* format, it is not necessary to call this function, this is
    # done automatically, as needed.
    #
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes:
    #     - the dataset was opened in read-only mode.
    #     - the dataset is already in define mode.
    #     - the dataset is closed.
    def define_mode
      err = nc_redef(@id)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      @in_define_mode = true
    end

    # Enter into the data mode.
    #
    # That means that variable data can be read or written.
    #
    # This call may involve copying data under some circumstances (and thus,
    # performance penalty). Read
    # {this section}[http://www.unidata.ucar.edu/software/netcdf/docs/netcdf/Parts-of-a-NetCDF-Classic-File.html#Parts-of-a-NetCDF-Classic-File]
    # of the documentation to understand why and how to avoid it.
    #
    # For *NETCDF4* format, it is not necessary to call this function, this is
    # done automatically, as needed.
    #
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes include:
    #     - the dataset is closed.
    #     - the dataset is already in data mode.
    #     - at least one variable size constraint is exceeded for the file
    #     format in use (more information about the constraints
    #     here[http://www.unidata.ucar.edu/software/netcdf/docs/netcdf/Large-File-Support.html#Large-File-Support]).
    def data_mode
      err = nc_enddef(@id)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      @in_define_mode = false
    end

    # Close the dataset.
    #
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes include:
    #     - the dataset is already closed.
    #     - the dataset was in define mode and the automatic call to data_mode
    #     failed.
    def close
      err = nc_close(@id)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
    end

    # Write all buffered data in the dataset to the disk.
    #
    # * *Raises* :
    #   - +NetCDFError+ -> possible causes include:
    #     - the dataset is already closed.
    #     - dataset is in define mode.
    def sync
      err = nc_sync(@id)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
    end


    # Test if the file is in define mode.
    #
    # * *Returns* :
    #   - true if the file is in define mode, false if it is in data mode.
    def define_mode?
      @in_define_mode
    end

    attr_reader :id
    attr_reader :format
    attr_reader :dimensions

    private

    # Convert the optional arguments into flag for C function.
    #
    # * *Args*    :
    #   - +opts+ -> optional arguments.
    # * *Returns* :
    #   - the flag.
    # * *Raises* :
    #   - +ArgumentError+ -> possible causes include:
    #     - invalid mode.
    #     - invalid format.
    def opts_to_flag(opts)
      # Validity checks.
      unless SUPPORTED_MODE.include? opts[:mode]
        fail ArgumentError.new("Invalid mode (#{opts['mode']}), must be 'r', "\
                               "'w' or 'r+'")
      end
      unless SUPPORTED_FORMAT.include? opts[:format]
        fail ArgumentError.new("Invalid format (#{opts['format']}), must be " \
                               "'NETCDF3', 'NETCDF3_64BIT', 'NETCDF4' or "    \
                               "'NETCDF4_CLASSIC'")
      end
      # Correct the options' compatibility.
      opts[:clobber] = false if opts[:mode] != 'w'
      # The shared mode is available only for the netCDF-3 files.
      opts[:share] = false unless opts[:format].include? '3'
      # Flag setting.
      flag = 0
      flag |= NC_SHARE         if opts[:share]
      flag |= NC_WRITE         if opts[:mode] == 'w' || opts[:mode] == 'r+'
      flag |= NC_NOWRITE       if opts[:mode] == 'r'
      flag |= NC_64BIT_OFFSET  if opts[:format] == 'NETCDF3_64BIT'
      flag |= NC_CLASSIC_MODEL if opts[:format] == 'NETCDF4_CLASSIC'
      flag |= NC_NETCDF4       unless opts[:format].include? '3'
      flag |= opts[:clobber] ? NC_CLOBBER : NC_NOCLOBBER

      return flag
    end

    # Load the existing dimensions from the opened dataset.
    #
    # * *Returns* :
    #   - the dimensions, indexed by name.
    def load_dimensions
      dimensions = {}
      # Retrieve the total number of dimensions.
      nb_dim_ptr = FFI::MemoryPointer.new(:int)
      err = LibNetCDF.nc_inq_ndims(@id, nb_dim_ptr)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      # Retrieve the IDs of the unlimited dimensions.
      unlim_ids = fetch_unlimdims_ids()
      # Load each dimension.
      nb_dim_ptr.read_int.times do |dim_id|
        dim = Dimension.load_dimension(@id, dim_id, unlim_ids.include?(dim_id))
        dimensions[dim.name] = dim
      end

      return dimensions
    end

    # Retrieve the IDs of the unlimited dimensions.
    #
    # * *Returns* :
    #   - IDs of the unlimited dimensions.
    def fetch_unlimdims_ids
      if @format == 'NETCDF4' # Can have many unlimited dimensions.
        # Retrieve the number of unlimited dimensions.
        nb_udim_ptr = FFI::MemoryPointer.new(:int)
        err = LibNetCDF.nc_inq_unlimdims(@id, nb_udim_ptr, nil)
        fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
        nb_udim = nb_udim_ptr.read_int
        # Retrieve the IDs of the unlimited dimensions.
        udim_id = FFI::MemoryPointer.new(:int, nb_udim)
        err = LibNetCDF.nc_inq_unlimdims(@id, nil, udim_id)
        fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
        return Set.new(udim_id.get_array_of_int(0, nb_udim))
      else # Only one unlimited dimension ("nc_inq_unlimdims" not available)
        id_ptr = FFI::MemoryPointer.new(:int)
        err = LibNetCDF.nc_inq_unlimdim(@id, id_ptr)
        fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
        id = id_ptr.read_int
        return Set.new(id == -1 ? [] : [id])
      end
    end
  end
end
