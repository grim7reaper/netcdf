#encoding: utf-8

require 'ffi/dataset'

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
    #   - +ArgumentError+ -> if the mode or the format is invalid.
    #   - +NetCDFError+   -> if an error occurs when creating a new dataset (or
    #     during opening an existing one).
    def initialize(filepath, opts={})
      # Retrieve the optional arguments.
      defaults = { mode:'r', clobber:true, share:false, format: 'NETCDF3' }
      opts = defaults.merge(opts)
      # Prepare the input parameters.
      cmode = opts_to_flag(opts)
      id_ptr = FFI::MemoryPointer.new(:int)
      # Open the NetCDF file.
      if opts[:mode] == 'w'
        err = nc_create(filepath, cmode, id_ptr)
      else
        err = nc_open(filepath, cmode, id_ptr)
      end
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
      # Retrieve the netCDF ID.
      @id = id_ptr.read_int
    end

    # Close the dataset.
    #
    # * *Raises* :
    #   - +NetCDFError+ -> if an error occurs.
    def close
      err = nc_close(@id)
      fail NetCDFError.new(nc_strerror(err)) unless err == NC_NOERR
    end

    attr_reader :id

    private

    # Convert the optional arguments into flag for C function.
    #
    # * *Args*    :
    #   - +opts+ -> optional arguments.
    # * *Returns* :
    #   - the flag.
    # * *Raises* :
    #   - +ArgumentError+ -> if the mode or the format is invalid.
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
      flag |= NC_WRITE         if opts[:mode] == 'w' || opts['mode'] == 'r+'
      flag |= NC_NOWRITE       if opts[:mode] == 'r'
      flag |= NC_64BIT_OFFSET  if opts[:format] == 'NETCDF3_64BIT'
      flag |= NC_CLASSIC_MODEL if opts[:format] == 'NETCDF4_CLASSIC'
      flag |= NC_NETCDF4       unless opts[:format].include? '3'
      flag |= opts[:clobber] ? NC_CLOBBER : NC_NOCLOBBER

      return flag
    end
  end
end
