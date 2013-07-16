open('lib/netcdf.rb') do |file|
  file.each_line do |line|
    if /VERSION = \[([^\]]+)\]/ =~ line
      VERSION = $1.split(', ').join('.')
      break
    end
  end
end

Gem::Specification.new do |spec|
  spec.name        = 'netcdf'
  spec.version     = VERSION
  spec.date        = Time.now.strftime("%F")
  spec.summary     = 'A Ruby interface to the NetCDF library'
  spec.license     = 'BSD2'
  spec.homepage    = ''
  spec.description = <<-eos
                     A Ruby interface to the NetCDF library.
                     It is built on the NMatrix library and uses Ruby-FFI.
                     eos
  spec.authors       = ['Sylvain Laperche']
  spec.email         = 'sylvain.laperche@gmx.fr'
  spec.require_paths = [ 'lib' ]
  spec.files         = `git ls-files`.split("\n") - [ '.gitignore', __FILE__ ]
  spec.test_files    = [ 'test/ts_NetCDF.rb' ]

  spec.extra_rdoc_files = ['README.rdoc', 'LICENSE']
  spec.rdoc_options     = [ 'lib', '-t', 'NetCDF', '-m', 'README.rdoc' ]

  spec.add_dependency  'nmatrix', '0.0.4'
  spec.add_dependency  'ffi'    , '~> 1.0'
  spec.requirements << 'libnetcdf'
end
