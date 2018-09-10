# Set the value of $(MSVCDir) for your installation. 
# Please note that none of the directory names are allowed to have spaces 
# in them. You must use the short name 
#
# "C:\Program Files\Microsoft Visual Studio\VC98" will not work.
# "C:\Progra~1\Micros~1\VC98" will work.
# MSVCDir="C:\PROGRA~1\MICROS~1.NET\Vc7"

MSVCDir="C:\PROGRA~1\Micros~3\VC98"

CPP=cl.exe
LINK32=link.exe

LIBOGG_PATH="..\..\xiph.org\ogg\win32\Dynamic_Release"
INCOGG_PATH="..\..\xiph.org\ogg\include"

LINK32_FLAGS=$(LIBOGG_PATH)\ogg.lib /nologo /dll /incremental:no /libpath:"$(MSVCDir)\Lib" /implib:".\liboggz.lib" /machine:I386 /out:".\liboggz.dll" 

PROG_LINK_FLAGS=/nologo /incremental:no /libpath:"$(MSVCDir)\Lib" /machine:I386 /exetype:dynamic

CFLAGS=/nologo /MD /W1 /GX /O2 /I"." /I"..\src\liboggz" /I"..\include" /I$(INCOGG_PATH) /I"$(MSVCDir)\Include"  /D "WIN32" /D "_USRDLL" /YX /FD


#====================================================================
# Targets

ALL :  "attgetopt.obj" "liboggz.dll" "oggzdump.exe" "oggzinfo.exe" "oggzed.exe"

CLEAN:
	-@erase ".\*.obj"
	-@erase ".\vc60.idb"
	-@erase ".\liboggz.dll"
	-@erase ".\liboggz.exp"
	-@erase ".\liboggz.lib"

#====================================================================

LINK32_OBJS= \
	".\oggz.obj" \
	".\oggz_io.obj" \
	".\oggz_read.obj" \
	".\oggz_write.obj" \
	".\oggz_auto.obj" \
	".\oggz_table.obj" \
	".\oggz_vector.obj"

"liboggz.dll" : $(LINK32_OBJS) ".\liboggz.def"
    $(LINK32) $(LINK32_FLAGS) /def:".\liboggz.def" $(LINK32_OBJS)

"oggzdump.exe" : "..\src\tools\oggzdump.c"
	$(CPP) $(CFLAGS) /Fo".\oggzdump.obj" /c "..\src\tools\oggzdump.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"oggzdump.exe" ".\oggzdump.obj" ".\attgetopt.obj" liboggz.lib

"oggzinfo.exe" : "..\src\tools\oggzinfo.c"
	$(CPP) $(CFLAGS) /Fo".\oggzinfo.obj" /c "..\src\tools\oggzinfo.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"oggzinfo.exe" ".\oggzinfo.obj" ".\attgetopt.obj" liboggz.lib

"oggzed.exe" : "..\src\tools\oggzed.c"
	$(CPP) $(CFLAGS) /Fo".\oggzed.obj" /c "..\src\tools\oggzed.c"
	$(LINK32) $(PROG_LINK_FLAGS) /out:"oggzed.exe" ".\oggzed.obj" ".\attgetopt.obj" liboggz.lib

#====================================================================
# C files in src

.\oggz.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz.obj" /c "..\src\liboggz\oggz.c"

.\oggz_io.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_io.obj" /c "..\src\liboggz\oggz_io.c"

.\oggz_read.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_read.obj" /c "..\src\liboggz\oggz_read.c"

.\oggz_write.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_write.obj" /c "..\src\liboggz\oggz_write.c"

.\oggz_auto.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_auto.obj" /c "..\src\liboggz\oggz_auto.c"

.\oggz_table.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_table.obj" /c "..\src\liboggz\oggz_table.c"

.\oggz_vector.obj:
	$(CPP) $(CFLAGS) /Fo".\oggz_vector.obj" /c "..\src\liboggz\oggz_vector.c"

.\attgetopt.obj:
	$(CPP) $(CFLAGS) /Fo".\attgetopt.obj" /c ".\attgetopt.c"

# End of Makefile
#====================================================================

