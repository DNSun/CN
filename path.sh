export KALDI_ROOT=`pwd`/../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
export PATH=/Users/dannysun/Documents/kaldi-master/tools/python:${PATH}
export LIBLBFGS=/Users/dannysun/Documents/kaldi-master/tools/liblbfgs-1.10
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${LIBLBFGS}/lib/.libs
export SRILM=/Users/dannysun/Documents/kaldi-master/tools/srilm
export PATH=${PATH}:${SRILM}/bin:${SRILM}/bin/macosx
