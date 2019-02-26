import os
import re
mypath = r'/Users/dannysun/Documents/kaldi-master/egs/CN/data_sources'
pattern = re.compile(r'(.*?).wav')
with open('wav.scp', 'w') as f:
    g = os.walk(mypath)
    for path, dir_list, file_list in g:
        dir_list.sort()
        for dir_name in dir_list:
            os.chdir(os.path.join(path, dir_name))
            # print(os.listdir())
            wavs = os.listdir()
            wavs.sort()
            for wav in wavs:
                utt = re.match(pattern, wav)
                if utt:
                    f.writelines(
                        utt.group(1) + ' ' + mypath + '/' + dir_name + '/' +
                        wav + '\n')
