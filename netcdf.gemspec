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
  spec.authors     = 'Sylvain Laperche'
  spec.email       = 'sylvain.laperche@gmail.com'
  spec.summary     = 'A Ruby interface to the NetCDF library'
  spec.license     = 'BSD3'
  spec.homepage    = ''
  spec.description = <<-eos
                     A Ruby interface to the NetCDF library.
                     It is built on the NMatrix library and uses Ruby-FFI.
                     eos
  spec.require_paths = [ 'lib' ]
  spec.files         = `git ls-files`.split("\n") - [ '.gitignore', '.yardopts',
                                                      __FILE__ ]
  spec.test_files    = [ 'test/ts_NetCDF.rb' ]
  spec.has_rdoc      = 'yard'

  spec.requirements << 'libnetcdf'
  spec.add_dependency             'nmatrix', '0.0.9'
  spec.add_dependency             'ffi'    , '~> 1.9'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'

end
