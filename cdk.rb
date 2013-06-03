require 'formula'

class Cdk < Formula
  homepage 'http://invisible-island.net/cdk/'
  url 'ftp://invisible-island.net/cdk/cdk-5.0-20120323.tgz'
  sha1 '014a32b1a2928bb0ab1917b7d15b9cdd1e23f33f'
  version '5.0.20120323'

  def install
    ENV.append 'CFLAGS', "-O2 -fPIC"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
    system "/usr/bin/ranlib #{lib}/libcdk.a"
    # Clean up generated header paths
    inreplace "#{include}/cdk.h" do |s|
      for obj in ["scale", "slider"]
        for dt in ["", "u", "d", "f"]
          s.sub! "#include <#{dt}#{obj}.h>", "#include <cdk/#{dt}#{obj}.h>"
        end
      end
    end
  end
end
