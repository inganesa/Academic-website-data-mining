
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
echo "Enter your work-directory (this should contain data folder):"
#Sread workDir
WORK_DIR=/home/ramya/Documents/DataMining/UCI/2gram
echo "work directory set at ${WORK_DIR}"

echo "Enter number of columns(terms):"
read termCount

echo "Enter rank of SVD"
read rank
#get query vector before running this


echo "Get queryVec transpose"
# transpose queryVec
$MAHOUT transpose -i ${WORK_DIR}/genQuery  --numRows 1 --numCols $termCount

echo "Get final queryVec = answer"
#multiply queryVec with UTSigmaInverse
$MAHOUT matrixmult -nra $termCount -nca 1 -nrb $termCount -ncb $rank -ia ${WORK_DIR}/transpose-*/part-00000 -ib ${WORK_DIR}/UTSigmaInv/part-00000 -op ${WORK_DIR}/answerQueryVector

cp ${WORK_DIR}/answerQueryVector/part-00000 ${WORK_DIR}/svdQuery

#echo "Dump output"
# $MAHOUT vectordump -i ${WORK_DIR}/finalQuery -o ${WORK_DIR}/finalQueryDump

# Check closest document
#echo "Check closest document"
#read a

