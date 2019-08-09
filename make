#!/bin/bash

#---------------------------- SETTINGS ----------------------------#
GAME_NAME="RacingPlatformer"
#-------------------------- END SETTINGS --------------------------#

if [ "$1" = help ]; then
	echo "Help screen:
	Love2D genaric build script by BEN1JEN.
	usage: ./make [mode] [zip]
	[mode]:
		none					- Everything
		clean					- Remove all build files
		all					- Redownload and build everything
		love					- Just .love
		win64					- Windows 64 bits
		macos					- MacOS
		linux					- Linux x86_64
		zip					- Same as love but also puts it into a All.zip
	[zip]:
		none					- don't zip
		zip					- do zip everything at the end

	This build script requires you have care, javac and appimagetool
	installed and in your path.

	This particular script is configured for building the game \"$GAME_NAME\".
"
	exit 0
fi

if [ ! -d build ]; then
	mkdir build
fi

if [ "$1" = clean -o "$1" = all ]; then
	rm -rf build
	rm -rf "$GAME_NAME"_*.zip
	if [ "$1" = clean ]; then
		exit 0
	elif [ "$1" = all ]; then
		mkdir build
	fi
fi
pushd build

# make .love file
if [ -f tmp.zip ]; then
	rm tmp.zip
fi
cd ..
zip -r tmp.zip assets func *.lua LICENSE.md
mv tmp.zip build
cd build
mv tmp.zip $GAME_NAME.love
if [ "$1" = love ]; then
	exit 0
fi

# make .exe file
if [ $# -lt 1 -o "$1" = win64 -o "$1" = all ]; then
	if [ ! -d love_extracted_win64 ]; then
		wget https://bitbucket.org/rude/love/downloads/love-11.2-win64.zip
		mkdir love_extracted_win64
		unzip love-11.2-win64.zip -d love_extracted_win64
		rm love-11.2-win64.zip
	fi
	cat love_extracted_win64/love-11.2.0-win64/love.exe $GAME_NAME.love > "$GAME_NAME"_win64.exe

	# add icon to .exe file
	if [ ! -d org ]; then
		wget https://git.eclipse.org/c/equinox/rt.equinox.p2.git/plain/bundles/org.eclipse.equinox.p2.publisher.eclipse/src/org/eclipse/pde/internal/swt/tools/IconExe.java
		javac -d . IconExe.java
	fi
	java -cp . org.eclipse.pde.internal.swt.tools.IconExe "$GAME_NAME"_win64.exe ../assets/icon.ico

	# make windows ziped file
	if [ ! -d tmp ]; then
		mkdir tmp
	else
		rm -rf tmp/*
	fi
	cp "$GAME_NAME"_win64.exe tmp
	cp love_extracted_win64/love-11.2.0-win64/*.dll love_extracted_win64/love-11.2.0-win64/license.txt tmp
	if [ -f "$GAME_NAME"_win64.zip ]; then
		rm "$GAME_NAME"_win64.zip
	fi
	cd tmp
	zip -r ../"$GAME_NAME"_win64.zip *
	cd ..
	rm -rf tmp/*

	if [ "$1" = win64 ]; then
		cp "$GAME_NAME"_win64.zip ..
	fi
fi

# make MacOS .app
if [ $# -lt 1 -o "$1" = macos -o "$1" = all ]; then
	if [ ! -d love_extracted_macos ]; then
		mkdir love_extracted_macos
		wget https://bitbucket.org/rude/love/downloads/love-11.2-macos.zip
		mkdir love_extracted_macos
		unzip love-11.2-macos.zip -d love_extracted_macos
		rm love-11.2-macos.zip
	fi
	cp -r love_extracted_macos/love.app $GAME_NAME.app
	cp $GAME_NAME.love $GAME_NAME.app/Contents/Resources/
	cp ../assets/icon.icns $GAME_NAME.app/Contents/Resources/OS\ X\ AppIcon.icns
	if [ -f ../MacOS_Info.plist ]; then
		cp ../MacOS_Info.plist $GAME_NAME.app/Contents/Info.plist
		sed -i 's/${GAME_NAME}/'"$GAME_NAME"'/g' $GAME_NAME.app/Contents/Info.plist
	else
		echo "WARNING: MacOS_Info.plist file missing! You will have to modify $GAME_NAME.app/Contents/Info.plist Manualy."
	fi

	# make MacOS ziped file
	if [ -f "$GAME_NAME"_MacOS.zip ]; then
		rm "$GAME_NAME"_MacOS.zip
	fi
	zip -r "$GAME_NAME"_MacOS.zip $GAME_NAME.app

	if [ "$1" = win64 ]; then
		cp "$GAME_NAME"_macos.zip ..
	fi
fi

# make linux executable that MIGHT work on other computers
if [ $# -lt 1 -o "$1" = linux -o "$1" = all ]; then
	cat /usr/bin/love $GAME_NAME.love > $GAME_NAME.x86_64
	chmod a+x $GAME_NAME.x86_64

	# make .appimage file
	if [ ! -d love_extracted_linux ]; then
		mkdir love_extracted_linux
		care -o love.tar.gz love
		wget https://bitbucket.org/rude/love/downloads/love-11.2-x86_64.tar.gz
		tar -C love_extracted_linux -zxvf love.tar.gz
		tar -C love_extracted_linux -zxvf love-11.2-x86_64.tar.gz
		rm love.tar.gz
		rm love.tar-11.2-x86_64.gz
	fi
	cp -r love_extracted_linux/love/rootfs/* tmp
	if [ ! -d tmp/usr/lib ]; then
		mkdir tmp/usr/lib
	fi
	cp -r love_extracted_linux/love-11.2-x86_64/dest/usr/lib/* tmp/usr/lib
	cp $GAME_NAME.x86_64 tmp/usr/bin/$GAME_NAME
	sed -i -e 's#/usr#././#g' tmp/usr/bin/$GAME_NAME # magic to make it work in the appimage
	cp ../assets/icon.png tmp/$GAME_NAME.png
	echo "[Desktop Entry]
Name=$GAME_NAME
Comment=Saweron+BEN1JEN's Game $GAME_NAME
Exec=$GAME_NAME
Icon=$GAME_NAME
Terminal=false
Type=Application
Categories=Game;X-Love;
StartupNotify=true
Keywords=game;love;$GAME_NAME;" > tmp/$GAME_NAME.desktop
	if [ ! -f AppRun ]; then
		wget -c https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64 -O AppRun
		chmod a+x AppRun
	fi
	cp AppRun tmp/
	appimagetool tmp # in order to build, make sure you have appimagetool is /usr/bin
	mv $GAME_NAME-x86_64.AppImage $GAME_NAME.AppImage

	# make linux ziped
	rm -rf tmp/*
	cp $GAME_NAME.AppImage tmp
	cp $GAME_NAME.x86_64 tmp
	if [ -f "$GAME_NAME"_Linux.zip ]; then
		rm "$GAME_NAME"_Linux.zip
	fi
	cd tmp
	zip -r ../"$GAME_NAME"_Linux.zip *
	cd ..

	if [ "$1" = linux ]; then
		cp "$GAME_NAME"_Linux.zip ..
	fi
fi

# make universal ziped
if [ "$1" = zip -o "$2" = zip -o "$1" = all ]; then
	rm -rf tmp/*
	cp $GAME_NAME.love tmp
	if [ "$1" = win64 -o "$1" = all ]; then
		cp "$GAME_NAME"_win64.zip tmp
	fi
	if [ "$1" = macos -o "$1" = all ]; then
		cp "$GAME_NAME"_MacOS.zip tmp
	fi
	if [ "$1" = linux -o "$1" = all ]; then
		cp "$GAME_NAME"_Linux.zip tmp
	fi
	if [ -f "$GAME_NAME"_All.zip ]; then
		rm "$GAME_NAME"_All.zip
	fi
	cd tmp
	zip -r ../"$GAME_NAME"_All.zip *
	cd ..
	cp "$GAME_NAME"_All.zip ../"$GAME_NAME"_All.zip
fi

# finish up
rm -rf tmp
cd ..
popd
