#!/bin/bash

#PROJECT=../vector.argo
#PROJECT=../vector.aspect

#PROJECT=../../../../../Data/AppData/vector.aspect.jedit
#PROJECT=../../../../../Data/AppData/vector.aspect.argo
#PROJECT=../../../../../Data/AppData/vector.aspect.jdtcore
#PROJECT=../../../../../Data/AppData/vector.aspect.jhotdraw
#PROJECT=../../../../../Data/AppData/vector.aspect.tomcat

PROJECT=../../../../../Data/AppData/vector.aspect.argo.test

#TEX_VOCAB_FILE=$PROJECT/IdVocab.txt
#TEX_COOCCURRENCE_FILE=$PROJECT/IdCooccurrence.txt
#TEX_COOCCURRENCE_SHUF_FILE=$PROJECT/IdCooccurrence.shuf.bin
#TEX_SAVE_FILE=$PROJECT/IdVectors

TEX_VOCAB_FILE=$PROJECT/TexVocab.txt
TEX_COOCCURRENCE_FILE=$PROJECT/TexCooccurrence.txt
TEX_COOCCURRENCE_SHUF_FILE=$PROJECT/TexCooccurrence.shuf.bin
TEX_SAVE_FILE=$PROJECT/TexVectors

DEF_VOCAB_FILE=$PROJECT/DefVocab.txt
DEF_COOCCURRENCE_FILE=$PROJECT/DefCooccurrence.txt
DEF_COOCCURRENCE_SHUF_FILE=$PROJECT/DefCooccurrence.shuf.bin
DEF_SAVE_FILE=$PROJECT/DefVectors

#CON_VOCAB_FILE=$PROJECT/ConVocab.txt
#CON_COOCCURRENCE_FILE=$PROJECT/ConCooccurrence.txt
#CON_COOCCURRENCE_SHUF_FILE=$PROJECT/ConCooccurrence.shuf.bin
#CON_SAVE_FILE=$PROJECT/ConVectors

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
	if [[ $? -eq 0 ]]
	then
		./shuffle -memory $MEMORY -verbose $VERBOSE < $DEF_COOCCURRENCE_FILE > $DEF_COOCCURRENCE_SHUF_FILE
		if [[ $? -eq 0 ]]
		then
			./glove -initial-weight-file $TEX_SAVE_FILE -save-file $DEF_SAVE_FILE -threads $NUM_THREADS -input-file $DEF_COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $DEF_VOCAB_FILE -verbose $VERBOSE
#			if [[ $? -eq 0 ]]
#			then
#				./shuffle -memory $MEMORY -verbose $VERBOSE < $CON_COOCCURRENCE_FILE > $CON_COOCCURRENCE_SHUF_FILE
#				if [[ $? -eq 0 ]]
#				then
#					./glove -initial-weight-file $DEF_SAVE_FILE -save-file $CON_SAVE_FILE -threads $NUM_THREADS -input-file $CON_COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $CON_VOCAB_FILE -verbose $VERBOSE
#				fi
#			fi
		fi
	fi
fi



