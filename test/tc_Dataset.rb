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

  def test_read_only
    nc = Dataset.new('test/data/simple.nc')
    assert_raise NetCDFError do
      nc.define_mode()
    end
    nc.close()
  end

  def test_ID
    nc1 = Dataset.new('test/data/simple.nc')
    nc2 = Dataset.new('test/data/simple.nc')
    assert_not_equal(nc1.id, nc2.id)
    nc1.close()
    nc2.close()
  end

  def test_noclobber
    nc1 = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    assert_raise NetCDFError do
      nc2 = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    end
    nc1.close()
    File.delete('test/data/scratch.nc')
  end
  # TODO: Add more tests later (need nc_inq)

  #---------------------#
  # Dataset#define_mode #
  #---------------------#
  def test_redef_closed
    nc = Dataset.new('test/data/simple.nc')
    nc.close()
    assert_raise NetCDFError do
      nc.define_mode()
    end
  end

   def test_redef_read_only
    nc = Dataset.new('test/data/simple.nc')
    assert_raise NetCDFError do
      nc.define_mode()
    end
    nc.close()
  end

  def test_redef_in_define_mode
    nc = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    assert_raise NetCDFError do
      nc.define_mode()
    end
    nc.close()
    File.delete('test/data/scratch.nc')
  end


  # TODO: Add more tests later (need functions to add dim & var)

  #-------------------#
  # Dataset#data_mode #
  #-------------------#
  def test_enddef_closed
    nc = Dataset.new('test/data/simple.nc')
    nc.close()
    assert_raise NetCDFError do
      nc.data_mode()
    end
  end

  def test_enddef_in_data_mode
    nc = Dataset.new('test/data/simple.nc')
    assert_raise NetCDFError do
      nc.data_mode()
    end
    nc.close()
  end


  # TODO: Add more tests later (need functions to add dim & var)

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

  #--------------#
  # Dataset#sync #
  #--------------#
  def test_sync_closed
    nc = Dataset.new('test/data/simple.nc')
    nc.close()
    assert_raise NetCDFError do
      nc.sync()
    end
  end

  def test_sync_define_mode
    nc = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    assert_raise NetCDFError do
      nc.sync()
    end
    nc.close()
    File.delete('test/data/scratch.nc')
  end

  # TODO: Add more tests later (need functions to add dim & var)

  #----------------------#
  # Dataset#define_mode? #
  #----------------------#

  def test_on_open
    nc = Dataset.new('test/data/simple.nc')
    assert_equal(false, nc.define_mode?)
    nc.close()
  end

  def test_on_create
    nc = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    assert_equal(true, nc.define_mode?)
    nc.close()
    File.delete('test/data/scratch.nc')
  end

  def test_after_redef
    nc = Dataset.new('test/data/simple.nc', mode:'r+')
    assert_equal(false, nc.define_mode?)
    nc.define_mode()
    assert_equal(true, nc.define_mode?)
    nc.close()
  end

  def test_after_enddef
    nc = Dataset.new('test/data/scratch.nc', mode:'w', clobber:false)
    assert_equal(true, nc.define_mode?)
    nc.data_mode()
    assert_equal(false, nc.define_mode?)
    nc.close()
    File.delete('test/data/scratch.nc')
  end
end
