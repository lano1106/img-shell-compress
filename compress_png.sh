#! /bin/sh

for filename in "$@" ; do
    outfile=${filename%.png}.opt.png
    convert $filename -strip $outfile
    optipng -O7 $outfile
    let insize=$(stat -c%s "$filename")
    let outsize=$(stat -c%s "$outfile")
    if [ $insize -le $outsize ]; then
        echo "$filename already optimized"
        rm $outfile
    else
        let rate=($insize-$outsize)*100/$insize
        echo "$filename size: $insize opt: $outsize ($rate%)"
        mv $outfile $filename
    fi
done

