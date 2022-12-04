echo $1
echo $2
wget --header "`cat ../cookie.txt`" https://adventofcode.com/2022/day/$1/input --no-check-certificate
