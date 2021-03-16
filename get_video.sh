#!/bin/bash
#
#
# Youtube Video Downloader bash shell version
#
# usage: ./get_video.sh 'https://www.youtube.com/watch?v=xxxxxxxxxx'
#
#
#
# Rev 1.4
# 2013/09/03
# Copyright 2013 Jacky Shih <iluaster@gmail.com>
#
# Licensed under the GNU General Public License, version 2.0 (GPLv2)
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
# NON INFRINGEMENT.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#

#!/bin/bash

declare -i line=0

function video_select ()
{
	for i in `cat video_type_option.txt`
	do
		#    line=line+1
		((line++))
		echo "${line}.$i"
	done

	echo -e "\nWhich one ?"
	read n

	if [ "$n" -le "$line" ];
	then
		head -n "$n" yt_tmp4.txt | tail -n 1 > yt_tmp5.txt
	else
		echo "Input Error!!"
		exit
	fi
}

#process substitution
id_name=`perl -ne 'print "$1\n" if /v=(.*)/' <(echo $1)`

name="https://www.youtube.com/get_video_info?video_id=${id_name}"

wget "$name" -O "${id_name}_url.txt"

#cut and filter mp4 url

cp -- "${id_name}_url.txt" yt_tmp2.txt

#url_decode

sed -e 's/&/\n/g' -e 's/%2C/,/g' -e 's/,/\n/g' -e 's/%25/%/g' -e 's/%25/%/g' -e 's/%3A/:/g' -e 's/%2F/\//g' \
-e 's/%3F/\?/g' -e 's/%3D/=/g' -e 's/%26/\&/g' -e 's/&/\n/g' -e 's/url%3D//g' -e 's/\n//g' -e 's/sig%3D/\&signature%3D/g' \
-e 's/%2C/,/g' -e 's/%22/"/g' -e 's/%3B/;/g' -e 's/%7D/}/g' -e 's/%7B/{/g' -e 's/http/\nhttp/g' -e 's/%5C/\\/g' yt_tmp2.txt | \
perl -pe 's/\\u0026/\&/g'  > yt_tmp3.txt

#get video title name

echo -n "echo -e '" > title_name.sh
title_name=`perl -ne 'print "$1" if/title":"(.*?)"/' yt_tmp3.txt`
echo ${title_name} | perl -pe 's/\%/\\x/g' | tr -d '\n' >> title_name.sh

echo -n "'" >> title_name.sh
filename=`. title_name.sh`

#get video

grep qualityLabel yt_tmp3.txt | grep audioQuality > yt_tmp4.txt

perl -ne 'print "$1,$2\n" if /mimeType":"(.*?);.*quality":"(.*?)"/' yt_tmp4.txt > video_type_option.txt

video_select

extension_name=`perl -ne 'print "$1" if /mimeType":"video\/(.*?);/' yt_tmp5.txt`

quality_name=`perl -ne 'print "$1" if /"quality":"(.*?)"/;' yt_tmp5.txt`

perl -ne 'print "$1\n" if /^(http.*?)"/' yt_tmp5.txt > yt_url.txt

wget -O "${filename}_${id_name}_${quality_name}.${extension_name}" -i yt_url.txt

#delete tmp file
rm -f yt_tmp[2-5].txt
rm -f yt_url.txt
