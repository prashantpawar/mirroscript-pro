#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Assembling agl
/usr/bin/as -o agl.o agl.s -arch i386
if [ $? != 0 ]; then DoExitAsm agl; fi
rm agl.s
echo Assembling main
/usr/bin/as -o main.o main.s -arch i386
if [ $? != 0 ]; then DoExitAsm main; fi
rm main.s
echo Assembling teleprompters
/usr/bin/as -o teleprompters.o teleprompters.s -arch i386
if [ $? != 0 ]; then DoExitAsm teleprompters; fi
rm teleprompters.s
echo Linking teleprompters
OFS=$IFS
IFS="
"
/usr/bin/ld /usr/lib/crt1.o  -framework Carbon -framework OpenGL '-dylib_file' '/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib'   -dead_strip -x -multiply_defined suppress -L. -o teleprompters `cat link.res`
if [ $? != 0 ]; then DoExitLink teleprompters; fi
IFS=$OFS
