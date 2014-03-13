if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This runs svd. Make sure you have input files in work directory"
  exit
fi

MAHOUT="$MAHOUT_DIR/bin/mahout"

if [ ! -e $MAHOUT ]; then
  echo "Can't find mahout driver in $MAHOUT, cwd `pwd`, exiting.."
  exit 1
fi

#Setting working directory
echo "Enter your work-directory (this should contain SparseMatrix folder):"
read workDir
WORK_DIR=$workDir
echo "work directory set at ${WORK_DIR}"

echo "Creating seqdir"
#$MAHOUT seqdirectory -i ${WORK_DIR}/data -o ${WORK_DIR}/seqdir -c UTF-8 -chunk 5

#$MAHOUT seq2sparse   -i ${WORK_DIR}/seqdir/ -o ${WORK_DIR}/seqdirSparseSSVD --maxDFPercent 85 --namedVector -ng 2 -ml 300 -n 2

# rowid
$MAHOUT rowid -i ${WORK_DIR}/SparseMatrix/tf-vectors/part-r-00000 -o ${WORK_DIR}/DocTermMatrix

echo "Enter number of rows(documents):"
read documentCount

echo "Enter number of columns(terms):"
read termCount

echo "Enter rank of SVD"
read rank

# transpose
$MAHOUT transpose -i ${WORK_DIR}/DocTermMatrix/matrix --numRows $documentCount --numCols $termCount

cp ${WORK_DIR}/DocTermMatrix/transpose-*/part-00000 ${WORK_DIR}/TermDocMatrix

echo "DocIndex dump"
$MAHOUT seqdumper -i ${WORK_DIR}/DocTermMatrix/docIndex -o ${WORK_DIR}/DocIndexLookUpDump

#now ssvd
$MAHOUT ssvd -i ${WORK_DIR}/TermDocMatrix -o ${WORK_DIR}/ssvd --rank $rank --reduceTasks 1 --tempDir ${WORK_DIR}/temp

echo "Transpose U matrix"
# transpose U matrix
$MAHOUT transpose -i ${WORK_DIR}/ssvd/U/u-m-00000 --numRows $termCount --numCols $rank

#echo "Calculating reduced A for distance measures"
#instead
cp ${WORK_DIR}/ssvd/V/v-m-00000 ${WORK_DIR}/DMatrix

# run sigma and query
echo "Get sigma inverse and reduced named matrix" #and query vector"
read a

echo "Get UTSigmaInv"
# multiply UT with sigmaInverse = UTSigmaInv
$MAHOUT matrixmult -nra $rank -nca $termCount -nrb $rank -ncb $rank -ia ${WORK_DIR}/ssvd/U/transpose-*/part-00000 -ib ${WORK_DIR}/sigmaInverse -op ${WORK_DIR}/UTSigmaInv

read -p "Enter number of clusters : " clusters
read -p "Enter number of iterations: " iterations

echo "ssvd clusters"

$MAHOUT kmeans -i ${WORK_DIR}/ReducedNamedMatrix -c ${WORK_DIR}/ReducedDocTermMatrix-clusters -o ${WORK_DIR}/ReducedDocTermMatrix-kmeans -dm org.apache.mahout.common.distance.CosineDistanceMeasure -x $iterations -k $clusters -ow --clustering

$MAHOUT clusterdump -i ${WORK_DIR}/ReducedDocTermMatrix-kmeans/clusters-*-final -o ${WORK_DIR}/ReducedDocTermMatrix-kmeans/clusterdump \
    #-d ${WORK_DIR}/seqdirSparseSSVD/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 --pointsDir ${WORK_DIR}/ReducedDocTermMatrix-kmeans/clusteredPoints 

cp ${WORK_DIR}/ReducedDocTermMatrix-kmeans/clusters-*-final/part-r-00000 ${WORK_DIR}/svd-kMeansClusters

echo "general clusters"

$MAHOUT kmeans -i ${WORK_DIR}/SparseMatrix/tf-vectors -c ${WORK_DIR}/DocTermMatrix-clusters -o ${WORK_DIR}/DocTermMatrix-kmeans -dm org.apache.mahout.common.distance.CosineDistanceMeasure -x $iterations -k $clusters -ow --clustering

$MAHOUT clusterdump -i ${WORK_DIR}/DocTermMatrix-kmeans/clusters-*-final -o ${WORK_DIR}/DocTermMatrix-kmeans/clusterdump -d ${WORK_DIR}/SparseMatrix/dictionary.file-0 -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 --pointsDir ${WORK_DIR}/ReducedDocTermMatrix-kmeans/clusteredPoints

cp ${WORK_DIR}/DocTermMatrix-kmeans/clusters-*-final/part-r-00000 ${WORK_DIR}/general-kMeansClusters


