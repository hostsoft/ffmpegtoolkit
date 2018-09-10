# Set the value of $(MSVCDir) for your installation. 
# Please note that none of the directory names are allowed to have spaces 
# in them. You must use the short name 
#
# "C:\Program Files\Microsoft Visual Studio\VC98" will not work.
# "C:\Progra~1\Micros~1\VC98" will work.
MSVCDir="C:\PROGRA~1\MICROS~1.NET\Vc7"

# MSVCDir="C:\PROGRA~1\Micros~4\VC98"

CPP=cl.exe

LINK32=link.exe
LINK32_FLAGS=ogg.lib vorbis.lib libspeex.lib /nologo /dll /incremental:no /libpath:"$(MSVCDir)\Lib" /implib:".\libfishsound.lib" /machine:I386 /out:".\libfishsound.dll" 

PROG_LINK_FLAGS=/nologo /incremental:no /libpath:"$(MSVCDir)\Lib" /machine:I386 /exetype:dynamic

CFLAGS=/nologo /MD /W1 /GX /O2 /I"." /I"..\src\libfishsound" /I"..\include" /I"$(MSVCDir)\Include"  /D "WIN32" /D "_USRDLL" /YX /FD


#====================================================================
# Targets

ALL :  "libfishsound.dll" "fishsound-identify.exe" "fishsound-info.exe" "fishsound-encode.exe" "fishsound-decode.exe"

CLEAN:
	-@erase ".\*.obj"
	-@erase ".\vc60.idb"
	-@erase ".\libfishsound.dll"
	-@erase ".\libfishsound.exp"
	-@erase ".\libfishsound.lib"

#====================================================================

LINK32_OBJS= \
	".\fishsound.obj" \
	".\comments.obj" \
	".\speex.obj" \
	".\vorbis.obj" \
	".\fs_vector.obj"

"libfishsound.dll" : $(LINK32_OBJS) ".\libfishsound\libfishsound.def"
    $(LINK32) $(LINK32_FLAGS) /def:".\libfishsound\libfishsound.def" $(LINK32_OBJS)

"fishsound-identify.exe" : "..\src\examples\fishsound-identify.c"
	$(CPP) $(CFLAGS) /Fo".\fishsound-identify.obj" /c "..\src\examples\fishsound-identify.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"fishsound-identify.exe" ".\fishsound-identify.obj" liboggz.lib libfishsound.lib

"fishsound-info.exe" : "..\src\examples\fishsound-info.c"
	$(CPP) $(CFLAGS) /Fo".\fishsound-info.obj" /c "..\src\examples\fishsound-info.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"fishsound-info.exe" ".\fishsound-info.obj" liboggz.lib libfishsound.lib

"fishsound-encode.exe" : "..\src\examples\fishsound-encode.c"
	$(CPP) $(CFLAGS) /Fo".\fishsound-encode.obj" /c "..\src\examples\fishsound-encode.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"fishsound-encode.exe" ".\fishsound-encode.obj" liboggz.lib libfishsound.lib libspeex.lib libsndfile.lib

"fishsound-decode.exe" : "..\src\examples\fishsound-decode.c"
	$(CPP) $(CFLAGS) /Fo".\fishsound-decode.obj" /c "..\src\examples\fishsound-decode.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"fishsound-decode.exe" ".\fishsound-decode.obj" liboggz.lib libfishsound.lib libspeex.lib vorbis.lib libsndfile.lib


#====================================================================
# C files in src

.\fishsound.obj:
	$(CPP) $(CFLAGS) /Fo".\fishsound.obj" /c "..\src\libfishsound\fishsound.c"

.\comments.obj:
	$(CPP) $(CFLAGS) /Fo".\comments.obj" /c "..\src\libfishsound\comments.c"

.\speex.obj:
	$(CPP) $(CFLAGS) /Fo".\speex.obj" /c "..\src\libfishsound\speex.c"

.\vorbis.obj:
	$(CPP) $(CFLAGS) /Fo".\vorbis.obj" /c "..\src\libfishsound\vorbis.c"

.\fs_vector.obj:
	$(CPP) $(CFLAGS) /Fo".\fs_vector.obj" /c "..\src\libfishsound\fs_vector.c"

# End of Makefile
#====================================================================

