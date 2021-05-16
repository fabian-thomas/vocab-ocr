#!/bin/sh
# $1: path
# $2: image filename

path=$1
filename=$2

from_lang="eng"
to_lang="deu"

# split in half, color to gray
convert -threshold 50% -monochrome -crop 50%x100% +repage "$path/$filename" "$path/split.png"

ocr()
{
    tesseract -l "$1" "$2" stdout \
        | sed   -e 's/\[.*$//'      `# remove everything after [` \
                -e 's/,/;/'         `# replace , by ; (, is used as csv delimiter)` \
                -e 's/‘.*$//'       `# remove everything after ‘` \
                -e 's/".*$//'       `# remove everything after "` \
                -e 's/|.*$//'       `# remove everything after |` \
                -e '/^\W*$/d'       `# remove white lines` \
                -e 's/\s*$//'       `# remove trailing spaces` \
        > "$path/$1.txt"
}

# ocr from language
ocr "$from_lang" "$path/split-0.png"

# ocr to language
ocr "$to_lang" "$path/split-1.png"

# merge to csv
paste -d"," "$path/$from_lang.txt" "$path/$to_lang.txt" > "$path/out.csv"