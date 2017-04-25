#!/bin/bash

if [[ $# -ne 0 ]]; then
	printf "Usage: `basename $0`"
	exit -1
fi

command -v wget >/dev/null 2>&1 || { echo >&2 "[!] wget is required but is not installed. Aborting."; exit -2;}
command -v montage >/dev/null 2>&1 || { echo >&2 "[!] ImageMagick is required but is not installed. Aborting."; exit -3;}

# http://exploration.urban.free.fr/catacombes/v5-globale/TileGroup3/5-23-23.jpg
# TileGroup[0-3] / zoom-[0-23]-[0-23].jpg
url="http://exploration.urban.free.fr/catacombes/v5-globale/"
maxTile=23 # zoom = 5
fileName="Plan Catacombes Nexus 2011.jpg"

echo "[*] Downloading images..."
mkdir img && cd img

for (( i = 0; i <= 3; i++ )); do
	for (( j = 0; j <= $maxTile; j++ )); do
		for (( k = 0; k <= $maxTile; k++ )); do
			# download image only if it exists
			wget "$url/TileGroup$i/5-$j-$k.jpg" -q -nv --spider 
			if [[ $? == 0 ]]; then

				# put 0 in front of single number for image magick
				if [[ $j -le 9 ]]; then
					column=0$j
				else
					column=$j
				fi

				if [[ $k -le 9 ]]; then
					row=0$k
				else
					row=$k
				fi

				# inverted row and col in filename for image magick
				wget "$url/TileGroup$i/5-$j-$k.jpg" -nv -q -O $row-$column.jpg
			fi
		done
	done
done

echo "[*] Download done"
echo "[*] Starting compiling images"
montage -monitor *.jpg -geometry 100% -tile 24x24 -gravity NorthWest -background none ../tmp
echo "[*] Compilation done"

cd ..
rm -rf "img"
mv tmp "$fileName"
open "$fileName"
echo "[*] Finish"
exit 0