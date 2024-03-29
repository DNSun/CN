#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=4
lm_order=1
#corpus and trans directory
#thchs=~/Documents/kaldi-master/egs/thchs30/thchs30_openslr
rm -rf exp mfcc data/train/cmvn.scp data/train/feats.scp \
      data/train/split1 data/test/cmvn.scp data/test/feats.scp \
      data/test/split1 data/local/tmp \
echo
echo "===== FEATURES EXTRACTION ====="
echo
# Making feats.scp files

mfccdir=mfcc
#utils/validate_data_dir.sh data/train     # script for checking prepared data - here: for data/train directory
#utils/validate_data_dir.sh data/test
#utils/fix_data_dir.sh data/train          # tool for data proper sorting if needed - here: for data/train directory
#utils/fix_data_dir.sh data/test
# Uncomment and modify arguments in scripts below if you have any problems with data sorting
# utils/validate_data_dir.sh data/train     # script for checking prepared data - here: for data/train directory
# utils/validate_data_dir.sh data/test
# utils/fix_data_dir.sh data/train          # tool for data proper sorting if needed - here: for data/train directory
# utils/fix_data_dir.sh data/test

steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train \
                        exp/make_mfcc/train $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/test \
                        exp/make_mfcc/test $mfccdir
# Making cmvn.scp files
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir

loc=`which ngram-count`;
if [ -z $loc ]; then
    if uname -a | grep 64 >/dev/null; then
        sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
    else
        sdir=$KALDI_ROOT/tools/srilm/bin/i686
    fi
    if [ -f $sdir/ngram-count ]; then
        echo "Using SRILM language modelling tool from $sdir"
        export PATH=$PATH:$sdir
    else
        echo "SRILM toolkit is probably not installed. Instructions: tools/install_srilm.sh"
        exit 1
    fi
fi

local=data/local
mkdir $local/tmp
ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt \
            -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa

echo
echo "===== MAKING G.fst ====="
echo

lang=data/lang
arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt \
                          $local/tmp/lm.arpa $lang/G.fst
echo
echo "===== MONO TRAINING ====="
echo

steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono  || exit 1

echo
echo "===== MONO DECODING ====="
echo

utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
                exp/mono/graph data/test exp/mono/decode
local/score.sh data/test data/lang exp/mono/decode/

echo
echo "===== MONO ALIGNMENT ====="
echo

steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1

echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo

steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

echo
echo "===== TRI1 (first triphone pass) DECODING ====="
echo

utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
                exp/tri1/graph data/test exp/tri1/decode
local/score.sh data/test data/lang exp/tri1/decode

echo
echo "===== run.sh script is finished ====="
echo
