# Microsoft Developer Studio Project File - Name="liboggz" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=liboggz - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "liboggz.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "liboggz.mak" CFG="liboggz - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "liboggz - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "liboggz - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "liboggz - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBOGGZ_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MD /GX /O2 /I "." /I "..\src\liboggz" /I "..\include" /I "..\..\ogg\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBOGGZ_EXPORTS" /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 ogg.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /libpath:"..\..\ogg\win32\Dynamic_Release"

!ELSEIF  "$(CFG)" == "liboggz - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBOGGZ_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /Gm /GX /ZI /Od /I "." /I "..\src\liboggz" /I "..\include" /I "..\..\xiph.org\ogg\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBOGGZ_EXPORTS" /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ogg_static.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ogg.lib /nologo /dll /debug /machine:I386 /pdbtype:sept /libpath:"..\..\xiph.org\ogg\win32\Static_Release"

!ENDIF 

# Begin Target

# Name "liboggz - Win32 Release"
# Name "liboggz - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\liboggz.def
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\metric_internal.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_auto.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_io.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_read.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_seek.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_stream.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_table.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_vector.c
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_write.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\config.h
# End Source File
# Begin Source File

SOURCE=..\include\oggz\oggz.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_auto.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_byteorder.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_compat.h
# End Source File
# Begin Source File

SOURCE=..\include\oggz\oggz_constants.h
# End Source File
# Begin Source File

SOURCE=..\include\oggz\oggz_io.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_macros.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_private.h
# End Source File
# Begin Source File

SOURCE=..\include\oggz\oggz_table.h
# End Source File
# Begin Source File

SOURCE=..\src\liboggz\oggz_vector.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
