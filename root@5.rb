class RootAT5 < Formula
  desc "CERN's ROOT framework configured for IceCube"
  homepage "http://root.cern.ch"
  url "https://root.cern.ch/download/root_v5.34.38.source.tar.gz"
  version "5.34.38"
  sha256 "2c3bda69601d94836bdd88283a6585b4774eafc813deb6aa348df0af2922c4d2"
  head "https://github.com/root-mirror/root.git", branch: "v5-34-00-patches"
  bottle do
    root_url "https://code.icecube.wisc.edu/tools/bottles/"
    sha256 mojave: "deb661f3f9878b00e99032e16dadbb494423e8a522a94dddadf41cfef106423f"
  end

  depends_on "cmake" => :build
  depends_on "gsl"
  depends_on "pythia6"
  depends_on "python"
  depends_on "xrootd"  => :recommended
  depends_on "fftw" => :optional

  def install
    ENV["CC"]  = "cc"
    ENV["CXX"] = "c++"
    # brew audit doesn't like non-executables in bin
    # so we will move {thisroot,setxrd}.{c,}sh to libexec
    # (and change any references to them)
    inreplace Dir["config/roots.in", "config/thisroot.*sh",
                  "etc/proof/utils/pq2/setup-pq2",
                  "man/man1/setup-pq2.1", "README/INSTALL", "README/README"],
      /bin.thisroot/, "libexec/thisroot"

    # Determine architecture
    arch = "macosx64"

    # N.B. that it is absolutely essential to specify
    # the --etcdir flag to the configure script.  This is
    # due to a long-known issue with ROOT where it will
    # not display any graphical components if the directory
    # is not specified:
    # http://root.cern.ch/phpBB3/viewtopic.php?f=3&t=15072
    args = ["./configure",
            arch.to_s,
            "--all",
            "--enable-builtin-glew",
            "--prefix=#{prefix}",
            "--etcdir=#{prefix}/etc/root",
            "--mandir=#{man}"].join(" ")

    if build.with? "x11"
      depends_on "libx11"
    else
      args = [args, "--disable-x11"].join(" ")
    end

    args = std_cmake_args + %w[
      -Dall=ON
      -Dcling=OFF
      -Dbuiltin_glew=ON
      -Dbuiltin_cfitsio=OFF
      -Dcfitsio=on
      -Dmathmore=ON
      -Dminuit2=ON
      -Dmysql=OFF
      -Dpgsql=OFF
      -Dpython=ON
    ]
    mkdir "builddir" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"

      # needed to run test suite
      # prefix.install 'test'

      libexec.mkpath
      mv Dir["#{bin}/*.*sh"], libexec
    end
  end

  def caveats
    <<~EOS
            Because ROOT depends on several installation-dependent
            environment variables to function properly, you should
            add the following commands to your shell initialization
            script (.bashrc/.profile/etc.), or call them directly
            before using ROOT.
      #{"      "}
                For csh/tcsh users:
                  source `brew --prefix root`/libexec/thisroot.csh
                For bash/zsh users:
                  . $(brew --prefix root)/libexec/thisroot.sh
    EOS
  end

  test do
    system "make", "-C", "#{prefix}/test/", "hsimple"
    system "#{prefix}/test/hsimple"
  end
end
