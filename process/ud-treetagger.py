#!/usr/bin/env python3
import sys
import subprocess
import re
import pprint
import glob
import os
import random
import unicodedata
import collections
import csv
import string
import stanza
from pathlib import Path




try:
    import argparse
except ImportError:
    checkpkg.check(['python-argparse'])

import time
import socket

"""

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
"""

USAGE = './ud-treetagger.py -s <source_directory> -t <target_directory> -l <language> [-h] '

def build_parser():

    parser = argparse.ArgumentParser(description='ud-treetagger - treetagger based on stanza and UD')


    parser.add_argument('-s', '--source', required=True, help='Source for raw texts, must be dir/dir/dir')
    parser.add_argument('-t', '--target', required=True, help='Target destination for processed texts')
    parser.add_argument('-l', '--model', required=True, help='Specify language model e.g., en for English, zh for Chinese')
    parser.add_argument('-c', '--corpus', required=True, help='corpus is ciep?')

    return parser


def check_args(args):
    '''Exit if required arguments not specified'''
    check_flags = {}


import unicodedata, re

all_chars = (unichr(i) for i in range(0x110000))
control_chars = ''.join(map(chr, list(range(0,32)) + list(range(127,160))))

control_char_re = re.compile('[%s]' % re.escape(control_chars))

def sanitize(s):
    return unicodedata.normalize('NFC', control_char_re.sub(' ', s))


def preparetext(file_content):
    '''Clean up nasty characters'''
    output=sanitize(re.sub(r'(?m)^\@.*\n?',' ',file_content.replace('’', '\'').replace('‘', '\'')).replace('…',' ... ').replace('«',' " ').replace('»',' " ').replace('<BLOCK>',' ').replace('“',' " ').replace('„',' " ').replace('* * *',' . ').replace('‚','\''))
    return output



def preparenlp(model):
    try: 
        nlp = stanza.Pipeline(lang=model, processors='tokenize,pos,lemma')
        return nlp
    except:
        print(model+" not found. I'll try to download it...")
        try:
            stanza.download(model)
            nlp = stanza.load(model, ignore_tag_map=True)
            return nlp
        except:
            custom = input("Please insert the path to the custom model:")
            nlp = stanza.load_from_path(lang=model,
                                  path=custom,
                                  meta={"description": "Custom model"})
            return nlp


def udparser(nlp,text,vrtfile):
    doc = nlp(text)
    for i, sentence in enumerate(doc.sentences):
        vrtfile.write("<s>"+"\n")
        #vrtfile.write("# sent_id = "+metadata['title']+"-s"+str(i+1)+"\n")        
        #vrtfile.write("# text = "+sentence.text+"\n")
        for word in sentence.words:
            vrtfile.write(word.text+"\t"+word.lemma+"\t"+word.pos)
            vrtfile.write("\n")
        vrtfile.write("</s>"+"\n")

def main():
    global debug
    global args
    global seppath
    global ud
    parser = build_parser()
    args = parser.parse_args()
    ud = args.model

    seppath = '/'
    '''Check arguments'''    
    if check_args(args) is False:
     sys.stderr.write("There was a problem validating the arguments supplied. Please check your input and try again. Exiting...\n")
     sys.exit(1)
    '''Unknown function, I'll check it later''' 
    start_time = time.time()
    import platform
    if platform.system() == 'Windows':
        seppath = '\\'
    '''Try to load the model into the parser'''
    nlp = preparenlp(ud)
    for filename in sorted(glob.glob(args.source+'/*.txt')):
        file_content = open(filename, encoding='utf-8').read()
        print("Reading: "+filename)
        vrtfile= open(args.target+Path(filename).stem+".vrt","a+",encoding='utf-8')
        if args.corpus == "CIEP":
            '''Extract metadata - valid for CIEP only'''
            header = re.findall(r'^@.*',file_content)
            '''Format and print header'''
            for feature in header:
                if feature != '@endheader':
                    value = feature.split('=')
                    metafile.write(re.sub('^@','',value[0])+"=\""+value[1]+"\" ")
                    metafile.write(">")
                    metafile.close()
            text=preparetext(file_content)
        else:
            lang=Path(filename).stem.split("_")[1]
            title=Path(filename).stem.split("_")[0]
            vrtfile.write("<text id=\""+title+"\" ")
            vrtfile.write("origtitle=\""+title+"\" language=\""+lang+"\" >\n")
            print("Starting parser...")
            udparser(nlp,file_content,vrtfile)
            vrtfile.write("</text>")
            vrtfile.close()
    print("--- %s seconds ---" % (time.time() - start_time))
    print("Done! Happy corpus-based typological linguistics!\n")

if __name__ == "__main__":
    main()
    sys.exit(0)

