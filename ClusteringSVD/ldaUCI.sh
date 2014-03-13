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
choice=3
clusters=20

algorithm=( kmeans fuzzykmeans dirichlet minhash )

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]} Clustering"
clustertype=${algorithm[$choice-1]} 

if [ "$choice" = "1" ] || [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
  read -p "Enter number of iterations: " iterations
fi


if [ "x$clustertype" == "xdirichlet" ]; then

  $MAHOUT dirichlet \
   -i ${WORK_DIR}/tokens/tf-vectors \
    -o ${WORK_DIR}/reuters-dirichlet -k $clusters -ow -x $iterations -a0 2 \
    -md org.apache.mahout.clustering.dirichlet.models.DistanceMeasureClusterDistribution \
    -mp org.apache.mahout.math.DenseVector \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
  && \
  $MAHOUT clusterdump \
    -i ${WORK_DIR}/reuters-dirichlet/clusters-*-final \
    -o ${WORK_DIR}/reuters-dirichlet/clusterdump \
    -d ${WORK_DIR}/tokens/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 -sp 0 \
    && \
  cat ${WORK_DIR}/reuters-dirichlet/clusterdump

else 
  echo "unknown cluster type: $clustertype"
fi 



