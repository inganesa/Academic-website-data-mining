#!/bin/bash
#

#
# To run:  change into the directory and type:
#  clustering.sh

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This runs clustering. Make sure you have input files in work directory"
  exit
fi

MAHOUT="$MAHOUT_DIR/bin/mahout"

if [ ! -e $MAHOUT ]; then
  echo "Can't find mahout driver in $MAHOUT, cwd `pwd`, exiting.."
  exit 1
fi

#Setting working directory
echo "Enter your work-directory (this should contain data folder):"
read workDir
WORK_DIR=$workDir
echo "work directory set at ${WORK_DIR}"

algorithm=( kmeans fuzzykmeans dirichlet minhash)
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
  read -p "Enter number of clusters : " clusters
  read -p "Enter number of iterations: " iterations
fi

echo "Creating seqdir"
$MAHOUT seqdirectory -i ${WORK_DIR}/data -o ${WORK_DIR}/reuters-out-seqdir -c UTF-8 -chunk 5

if [ "x$clustertype" == "xkmeans" ]; then
  $MAHOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans --maxDFPercent 85 --namedVector \
  && \
  $MAHOUT kmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-kmeans-clusters \
    -o ${WORK_DIR}/reuters-kmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x $iterations -k $clusters -ow --clustering \
  && \
  $MAHOUT clusterdump \
    -i ${WORK_DIR}/reuters-kmeans/clusters-*-final \
    -o ${WORK_DIR}/reuters-kmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/reuters-kmeans/clusteredPoints \
    && \
  cat ${WORK_DIR}/reuters-kmeans/clusterdump
elif [ "x$clustertype" == "xfuzzykmeans" ]; then
  $MAHOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans --maxDFPercent 85 --namedVector \
  && \
  $MAHOUT fkmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-fkmeans-clusters \
    -o ${WORK_DIR}/reuters-fkmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x $iterations -k $clusters -ow -m 1.1 \
  && \
  $MAHOUT clusterdump \
    -i ${WORK_DIR}/reuters-fkmeans/clusters-*-final \
    -o ${WORK_DIR}/reuters-fkmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 -sp 0 \
    && \
  cat ${WORK_DIR}/reuters-fkmeans/clusterdump
elif [ "x$clustertype" == "xdirichlet" ]; then
  $MAHOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-dirichlet  --maxDFPercent 85 --namedVector \
  && \
  $MAHOUT dirichlet \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-dirichlet/tfidf-vectors \
    -o ${WORK_DIR}/reuters-dirichlet -k $clusters -ow -x $iterations -a0 2 \
    -md org.apache.mahout.clustering.dirichlet.models.DistanceMeasureClusterDistribution \
    -mp org.apache.mahout.math.DenseVector \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
  && \
  $MAHOUT clusterdump \
    -i ${WORK_DIR}/reuters-dirichlet/clusters-*-final \
    -o ${WORK_DIR}/reuters-dirichlet/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-dirichlet/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 -sp 0 \
    && \
  cat ${WORK_DIR}/reuters-dirichlet/clusterdump
elif [ "x$clustertype" == "xminhash" ]; then
  $MAHOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-minhash --maxDFPercent 85 --namedVector \
  && \
  $MAHOUT org.apache.mahout.clustering.minhash.MinHashDriver \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-minhash/tfidf-vectors \
    -o ${WORK_DIR}/reuters-minhash --overwrite
else 
  echo "unknown cluster type: $clustertype"
fi 
