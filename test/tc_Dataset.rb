#encoding: utf-8

require 'test/unit'

require 'netcdf'
include NetCDF

class TestDataset < Test::Unit::TestCase
  #--------------#
  # Dataset::new #
  #--------------#
  def test_nonexistent
    assert_raise NetCDFError do
      Dataset.new('fairy_file.nc')
    end
  end

  def test_not_NetCDF
    assert_raise NetCDFError do
      Dataset.new(__FILE__)
    end
  end

  # nc_redef required for this test.
  # def test_read_only
  #   nc = Dataset.new('test/data/simple.nc')
  #   ...
  # end

  def test_ID
    nc1 = Dataset.new('test/data/simple.nc')
    nc2 = Dataset.new('test/data/simple.nc')
    assert_not_equal(nc1.id, nc2.id)
    nc1.close()
    nc2.close()
  end

  # Add more tests on Dataset::new later (need nc_inq)

  #---------------#
  # Dataset#close #
  #---------------#
  def test_close_twice
    nc = Dataset.new('test/data/simple.nc')
    nc.close()
    assert_raise NetCDFError do
      nc.close()
    end
  end

  def test_close_define_mode
    nc = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    nc.close()
    File.delete('test/data/scratch.nc')
  end

  def test_close_data_mode
    nc = Dataset.new('test/data/simple.nc')
    nc.close()
  end
end
