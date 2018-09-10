Name:           amrnb
Version:        11.0.0.0
Release:        0
URL:            http://www.penguin.cz/~utx/amr
Group:          System/Libraries
License:        Commercial
Summary:        Adaptive Multi-Rate (AMR) Speech Codec
Source:         http://ftp.penguin.cz/pub/users/utx/amr/%{name}-%{version}.tar.bz2
Autoreqprov:    on
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Adaptive Multi-Rate Narrow-Band decoder and encoder library.
(3GPP TS 26.104 V 11.0.0)

http://www.3gpp.org/ftp/Specs/html-info/26104.htm

%package devel
Group:          System/Libraries
Summary:        Adaptive Multi-Rate (AMR) Speech Codec
Requires:       %{name} = %{version} glibc-devel

%description devel
Adaptive Multi-Rate Narrow-Band decoder and encoder library.
(3GPP TS 26.104 V 11.0.0)

http://www.3gpp.org/ftp/Specs/html-info/26104.htm

%prep
%setup -q

%build
%configure
make %{?jobs:-j %jobs}
#make distcheck

%install
%makeinstall

%clean
rm -rf $RPM_BUILD_ROOT

%post
%run_ldconfig

%postun
%run_ldconfig

%files
%defattr (-, root, root)
%doc AUTHORS ChangeLog COPYING NEWS README TODO readme.txt
%{_bindir}/*
%{_libdir}/*.so.*

%files devel
%defattr (-, root, root)
%{_includedir}/amrnb
%{_libdir}/*.so
%{_libdir}/*.*a
