#!/bin/bash

#PROJECT=../vector.argo
#PROJECT=../vector.aspect

#PROJECT=../../../../../Data/AppData/vector.termcode.jedit
PROJECT=../../../../../Data/AppData/vector.termcode.argo
#PROJECT=../../../../../Data/AppData/vector.termcode.jdtcore
#PROJECT=../../../../../Data/AppData/vector.termcode.jhotdraw
#PROJECT=../../../../../Data/AppData/vector.termcode.tomcat

TEX_VOCAB_FILE=$PROJECT/TCVocab.txt
TEX_COOCCURRENCE_FILE=$PROJECT/TCCooccurrence.txt
TEX_COOCCURRENCE_SHUF_FILE=$PROJECT/TCCooccurrence.shuf.bin
TEX_SAVE_FILE=$PROJECT/TCVectors

VERBOSE=2
MEMORY=4.0
VECTOR_SIZE=500
MAX_ITER=50
BINARY=1
NUM_THREADS=8
X_MAX=20

./shuffle -memory $MEMORY -verbose $VERBOSE < $TEX_COOCCURRENCE_FILE > $TEX_COOCCURRENCE_SHUF_FILE
if [[ $? -eq 0 ]]
then
	./glove -save-file $TEX_SAVE_FILE -threads $NUM_THREADS -input-file $TEX_COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $TEX_VOCAB_FILE -verbose $VERBOSE
fi