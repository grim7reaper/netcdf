#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

# FFI::Pointer does not provide a read_size_t methods, but I need it.
# The following code is an hack that provides a portable (I hope) implemention
# of the read_size_t method.
# Adapted from https://github.com/ffi/ffi/issues/118
module FFI
  class Pointer
    builtin_type = FFI::TypeDefs[:size_t]
    typename, _ = FFI::TypeDefs.find do |(name, type)|
      builtin_type == type && method_defined?("read_#{name}")
    end

    alias_method :read_size_t, "read_#{typename}" if typename
  end
end
