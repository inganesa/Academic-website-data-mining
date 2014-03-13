#!/bin/bash
#

#
# To run:  change into the directory and type:
#  clustering.sh

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This runs clustering. Make sure you have input files in work directory"
  exit
fi
#export CUSTOM=/home/vmplanet/workspace/customAnalyzer/src
#export PATH=$PATH:$CUSTOM
MAHOUT="/home/vmplanet/trunk/bin/mahout"

if [ ! -e $MAHOUT ]; then
  echo "Can't find mahout driver in $MAHOUT, cwd `pwd`, exiting.."
  exit 1
fi

#Setting working directory
echo "Enter your work-directory (this should contain data folder):"
read workDir
WORK_DIR=$workDir
echo "work directory set at ${WORK_DIR}"

algorithm=( kmeans` fuzzykmeans dirichlet minhash )
if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding clustering algorithm"
  echo "1. ${algorithm[0]} clustering"
  echo "2. ${algorithm[1]} clustering"
  echo "3. ${algorithm[2]} clustering"
  echo "4. ${algorithm[3]} clustering"
  read -p "Enter your choice : " choice
fi

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]} Clustering"
clustertype=${algorithm[$choice-1]} 

if [ "$choice" = "1" ] || [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
  read -p "Enter number of iterations: " iterations
fi

echo "Creating seqdir"
$MAHOUT seqdirectory -i ${WORK_DIR}/data -o ${WORK_DIR}/reuters-out-seqdir -c UTF-8 -chunk 5

if [ "x$clustertype" == "xkmeans" ]; then
  $MAHOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans --maxDFPercent 85 --namedVector  -s 5 -md 5 -ng 2  -ml 100 -n 2 -seq\
    -a customanalyser.myanalyzer\
  && \

  $MAHOUT canopy \
	-i ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/tfidf-vectors/ \
	-o ${WORK_DIR}/reuters-canopy-centroids \
	-dm org.apache.mahout.common.distance.CosineDistanceMeasure \
	-t1 0.1 -t2 0.2 \
 && \
  $MAHOUT kmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-canopy-centroids/clusters-0-final \
    -o ${WORK_DIR}/reuters-kmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x $iterations -cd 0.1 -ow --clustering \
  && \
  $MAHOUT clusterdump \
    -i ${WORK_DIR}/reuters-kmeans/clusters-*-final \
    -o ${WORK_DIR}/reuters-kmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.TanimotoDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/reuters-kmeans/clusteredPoints \
    && \
  cat ${WORK_DIR}/reuters-kmeans/clusterdump

else 
  echo "unknown cluster type: $clustertype"
fi 



