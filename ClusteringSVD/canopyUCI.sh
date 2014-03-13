#!/bin/bash
#

#
# To run:  change into the directory and type:
#  clustering.sh

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This runs clustering. Make sure you have input files in work directory"
  exit
fi

MAHOUT="/home/vmplanet/trunk/bin/mahout"
WORK_DIR="/home/vmplanet/dm/UCI"
choice=1

algorithm=( kmeans fuzzykmeans dirichlet minhash )

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]} Clustering"
clustertype=${algorithm[$choice-1]} 

if [ "$choice" = "1" ] || [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
  read -p "Enter number of iterations: " iterations
fi


if [ "x$clustertype" == "xkmeans" ]; then

  $MAHOUT canopy \
	-i ${WORK_DIR}/tokens/tfidf-vectors/ \
	-o ${WORK_DIR}/reuters-canopy-centroids \
	-dm org.apache.mahout.common.distance.CosineDistanceMeasure \
	-t1 0.1 -t2 0.2 \
 && \
  $MAHOUT kmeans \
    -i ${WORK_DIR}/tokens/tfidf-vectors/ \
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



