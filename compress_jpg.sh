#! /bin/sh

for filename in "$@" ; do
    extension=${filename##*.}
    outfile=${filename%.$extension}.opttran.$extension
    jpegtran -optimize $filename > $outfile
    let insize=$(stat -c%s "$filename")
    let outsize=$(stat -c%s "$outfile")
    if [ $insize -le $outsize ]; then
        echo "$filename already optimized"
        rm $outfile
    else
        let rate=($insize-$outsize)*100/$insize
        echo "jpegtran stage: $filename size: $insize opt: $outsize ($rate%)"
        mv $outfile $filename
    fi

    # convert stage
    outfile1=${filename%.$extension}.c1.$extension
    outfile2=${filename%.$extension}.c2.$extension

    convert $filename -sampling-factor 4:2:0 -strip -quality 85 $outfile1
    convert $filename -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG $outfile2

    let cinsize=$(stat -c%s "$filename")
    let coutsize1=$(stat -c%s "$outfile1")
    let coutsize2=$(stat -c%s "$outfile2")

    if [ $coutsize2 -le $coutsize1 ]; then
        echo "Progressive smaller"
        rm $outfile1
        bestoutfile=$outfile2
        let bestsize=$coutsize2
    else
        echo "Baseline smaller"
        rm $outfile2
        bestoutfile=$outfile1
        let bestsize=$coutsize1
    fi

    if [ $cinsize -le $bestsize ]; then
        echo "$filename already optimized"
        rm $bestoutfile
    else
        let rate=($insize-$bestsize)*100/$insize
        echo "convert stage: $filename size: $insize opt: $bestsize ($rate%)"
        mv $bestoutfile $filename
    fi

done

