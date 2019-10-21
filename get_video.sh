#!/bin/bash
#
#
# Youtube Video Downloader bash shell version
#
# usage: ./get_video.sh 'https://www.youtube.com/watch?v=xxxxxxxxxx'
#
#
#
# Rev 1.3
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


declare -i line=0

function select_option ()
{
  for i in `cat video_type_option.txt`
  do
    ((line++))
    echo "${line}.$i"
  done

  echo -e "\nWhich one ?"
  read n

  if [ "$n" -le "$line" ];
  then
   head -n "$n" tmp3.txt | tail -n 1 > tmp4.txt
  else
   echo "Input Error!!"
   exit
  fi
}

#echo "$1" > youtube_tmp.txt

#Process substitution
  id_name=`perl -ne 'print "$1\n" if /v=(.*)/' <(echo $1)`

  name="https://www.youtube.com/get_video_info?video_id=${id_name}"

  wget "$name" -O "${id_name}_url.txt"

#cut and filter mp4 url
  cp -- "${id_name}_url.txt" tmp2.txt
  sed -e 's/&/\n/g' tmp2.txt| grep 'url_encoded_fmt_stream_map'> tmp3.txt
  sed -i -e 's/%2C/,/g' tmp3.txt 
  sed -i -e 's/,/\n/g' tmp3.txt

#print out total video format name and quality
  perl -ne 'print "$2,$1\n" if /quality%3D(.*?)%.*video%252F(.*?)(%|\n)/' tmp3.txt > video_type_option.txt

#if video format name is prior to quality
  perl -ne 'print "$1,$2\n" if /video%252F(.*?)%.*quality%3D(.*?)(%|\n)/' tmp3.txt >> video_type_option.txt
  sed -i -e 's/x-flv/flv/g' video_type_option.txt

  select_option
  
#set file extension name variable and video quality variable
  extension_name=`head -n "$n" video_type_option.txt | tail -n 1 | cut -d "," -f 1`
  quality_name=`head -n "$n" video_type_option.txt | tail -n 1 | cut -d "," -f 2`

  sed -i -e 's/%26/\&/g' tmp4.txt
  sed -i -e 's/&/\n/g' tmp4.txt
  grep 'http' tmp4.txt > tmp5.txt
  grep 'sig%3D' tmp4.txt >> tmp5.txt
  perl -pe 's/\n//g' tmp5.txt | sed -e 's/sig%3D/\&signature%3D/g' > tmp6.txt
  sed -i -e 's/url%3D//g' tmp6.txt
  
#url decoding
  cat tmp6.txt | sed -e 's/%25/%/g' -e 's/%25/%/g' -e 's/%3A/:/g' -e 's/%2F/\//g' -e 's/%3F/\?/g' -e 's/%3D/=/g' -e 's/%26/\&/g' > tmp7.txt

  wget -i tmp7.txt -O "${id_name}_${quality_name}.${extension_name}"
  
  rm -f tmp[2-6].txt

