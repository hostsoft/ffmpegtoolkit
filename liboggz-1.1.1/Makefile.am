#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE ORGANISATION OR
#  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
## Process this file with automake to produce Makefile.in

DISTCHECK_CONFIGURE_FLAGS = --enable-gcc-werror

SUBDIRS = doc include src

# pkg-config
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = oggz.pc

# Extra files to distribute in the source tarball.
EXTRA_DIST = PATCHES \
	oggz.pc.in oggz-uninstalled.pc.in \
	apache-install.sh \
	bash-completion/oggz \
	$(SYMBIAN_extra_dist) $(WIN32_extra_dist)

# Extra files to distribute for the Symbian build.
SYMBIAN_extra_dist = \
	README.symbian \
	symbian/bld.inf \
	symbian/config.h \
	symbian/liboggz.mmp

# Extra files to distribute for the Win32 build.
# Note that with Automake 1.9 it is possible to use wildcards instead of
# listing out files explicitly, ie.
#	win32/*.[ch] \
#	win32/*.def \
#	win32/*.dsp \
#	win32/*.dsw \
#	win32/VS200[35]/*.sln \
#	win32/VS200[35]/liboggz/*.vcproj \
# And with earlier versions, it is possible to use $(wildcard ...) if using
# GNU make.
# However, we list them out here for the sake of compatibility with earlier
# versions of Automake, and for portability with other vendors' make.
WIN32_extra_dist = \
	README.win32 \
	win32/attgetopt.c \
	win32/config.h \
	win32/getopt.h \
	win32/liboggz.def \
	win32/liboggz.dsp \
	win32/liboggz.dsw \
	win32/liboggz_bin_installer/liboggz_bin_installer.vdproj \
	win32/Makefile \
	win32/oggzdump.dsp \
	win32/oggzed.dsp \
	win32/oggzinfo.dsp \
	win32/oggzmerge.dsp \
	win32/strsep.c \
	win32/VS2003/liboggz.suo \
	win32/VS2003/liboggz/liboggz_dynamic.vcproj \
	win32/VS2003/liboggz/liboggz_static.vcproj \
	win32/VS2003/liboggz_dynamic.sln \
	win32/VS2003/liboggz_dynamic.suo \
	win32/VS2003/liboggz_static.sln \
	win32/VS2003/liboggz_static.suo \
	win32/VS2003/oggzdump/oggzdump_dynamic.vcproj \
	win32/VS2003/oggzdump/oggzdump_static.vcproj \
	win32/VS2003/oggzinfo/oggzinfo_dynamic.vcproj \
	win32/VS2003/oggzinfo/oggzinfo_static.vcproj \
	win32/VS2003/oggzmerge/oggzmerge_dynamic.vcproj \
	win32/VS2003/oggzmerge/oggzmerge_static.vcproj \
	win32/VS2003/oggzrip/oggzrip_dynamic.vcproj \
	win32/VS2003/oggzrip/oggzrip_static.vcproj \
	win32/VS2003/oggzscan/oggzscan_dynamic.vcproj \
	win32/VS2003/oggzscan/oggzscan_static.vcproj \
	win32/VS2003/oggzvalidate/oggzvalidate_dynamic.vcproj \
	win32/VS2003/oggzvalidate/oggzvalidate_static.vcproj \
	win32/VS2005/liboggz.suo \
	win32/VS2005/liboggz/liboggz_dynamic.vcproj \
	win32/VS2005/liboggz/liboggz_static.vcproj \
	win32/VS2005/liboggz_dynamic.sln \
	win32/VS2005/liboggz_dynamic.suo \
	win32/VS2005/liboggz_static.sln \
	win32/VS2005/liboggz_static.suo \
	win32/VS2005/oggzdump/oggzdump_dynamic.vcproj \
	win32/VS2005/oggzdump/oggzdump_static.vcproj \
	win32/VS2005/oggzinfo/oggzinfo_dynamic.vcproj \
	win32/VS2005/oggzinfo/oggzinfo_static.vcproj \
	win32/VS2005/oggzmerge/oggzmerge_dynamic.vcproj \
	win32/VS2005/oggzmerge/oggzmerge_static.vcproj \
	win32/VS2005/oggzrip/oggzrip_dynamic.vcproj \
	win32/VS2005/oggzrip/oggzrip_static.vcproj \
	win32/VS2005/oggzscan/oggzscan_dynamic.vcproj \
	win32/VS2005/oggzscan/oggzscan_static.vcproj \
	win32/VS2005/oggzvalidate/oggzvalidate_dynamic.vcproj \
	win32/VS2005/oggzvalidate/oggzvalidate_static.vcproj \
	win32/VS2008/liboggz.suo \
	win32/VS2008/liboggz/liboggz_dynamic.vcproj \
	win32/VS2008/liboggz/liboggz_static.vcproj \
	win32/VS2008/liboggz_dynamic.sln \
	win32/VS2008/liboggz_dynamic.suo \
	win32/VS2008/liboggz_static.sln \
	win32/VS2008/liboggz_static.suo \
	win32/VS2008/oggzdump/oggzdump_dynamic.vcproj \
	win32/VS2008/oggzdump/oggzdump_static.vcproj \
	win32/VS2008/oggzinfo/oggzinfo_dynamic.vcproj \
	win32/VS2008/oggzinfo/oggzinfo_static.vcproj \
	win32/VS2008/oggzmerge/oggzmerge_dynamic.vcproj \
	win32/VS2008/oggzmerge/oggzmerge_static.vcproj \
	win32/VS2008/oggzrip/oggzrip_dynamic.vcproj \
	win32/VS2008/oggzrip/oggzrip_static.vcproj \
	win32/VS2008/oggzscan/oggzscan_dynamic.vcproj \
	win32/VS2008/oggzscan/oggzscan_static.vcproj \
	win32/VS2008/oggzvalidate/oggzvalidate_dynamic.vcproj \
	win32/VS2008/oggzvalidate/oggzvalidate_static.vcproj
