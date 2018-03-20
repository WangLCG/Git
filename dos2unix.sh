#!/bin/sh
#Need to install dos2unix and enconv software first
#需要安装 dos2unix 和 enconv这两个软件
#使用：放到源码根目录然后执行，该脚本会将该目录下（包括子目录）所有.cpp/.c/.h文件转化为UNIX格式，文件编码转化为UTF-8 无BOM格式，TAB键转化为4个空格
#最后会输出一个log文件，该文件记录的是文件编码被转化的文件列表
#

echo "######### $(date) #########" > ChangedCodeFileList.log

echo "\033[31m Begin dos2unix convert process....\033[0m"
 find . -regex '.*\.cpp\|.*\.h\|.*\.c\|' | xargs dos2unix -q    # dos to unix quiet mode

 FILE=$(find . -regex '.*\.cpp\|.*\.h\|.*\.c\|')
 
 for filename in $FILE
 do
    sed -i 's/\t/    /g' $filename   # tab to space

    code=$(file $filename | awk '{print $2}')
    isbom=$(file $filename | awk '{print $4,$5}')
    #echo "$filename: $code $isbom"

    if [ "$code" != "UTF-8" ]; then
        enconv -L zh_CN -x UTF-8 $filename
        echo "Convered $filename:$code to utf8 " >> ChangedCodeFileList.log
    elif [ "$code" = "UTF-8" -a "$isbom" = "(with BOM)" ]; then
        sed -i '1 s/^\xef\xbb\xbf//' $filename    # utf-8 bom to utf -8 without bom
        echo "Convered $filename:$code $isbom to utf8 without BOM" >> ChangedCodeFileList.log
    fi

 done
echo "\033[31m End dos2unix convert process.\t You can see the result in ChangedCodeFileList.log \033[0m"

