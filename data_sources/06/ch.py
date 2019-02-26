import os
import re

for file in os.listdir('.'):
    if file[-4:] == '.wav':
        m = re.findall(r'\d+', file)
        os.rename(file, m[0].zfill(2) + '-' + m[1].zfill(3) + '.wav')
        #print(m[0].zfill(2) + '-' + m[1].zfill(3) + '.wav')
