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
from stanza.utils.conll import CoNLL




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

USAGE = './ud-stanza.py -s <source_directory> -t <target_directory> -l <language> -m <metadata_directory> [-h] '

def build_parser():

    parser = argparse.ArgumentParser(description='ud-stanza - build beautiful CoNLL-U files')


    parser.add_argument('-s', '--source', required=True, help='Source for raw texts, must be dir/dir/dir')
    parser.add_argument('-t', '--target', required=True, help='Target destination for processed texts')
    parser.add_argument('-l', '--model', required=True, help='Specify language model e.g., en for English, zh for Chinese')
    parser.add_argument('-p', '--processors', required=True, type=str, help='Specify NLP pipeline processors, e.g. tokenize,lemma,mwt,pos,depparse,ner')
    parser.add_argument('-m', '--metadata', required=True, help='path_to_metadata')

    return parser


def check_args(args):
    '''Exit if required arguments not specified'''
    check_flags = {}
    
#We redefine these methods to write NER (if available) in the misc column, instead of the char thing (stanza/utils/conll.py)

FIELD_NUM = 10

# TODO: unify this list with the list in common/doc.py
ID = 'id'
TEXT = 'text'
LEMMA = 'lemma'
UPOS = 'upos'
XPOS = 'xpos'
FEATS = 'feats'
HEAD = 'head'
DEPREL = 'deprel'
DEPS = 'deps'
MISC = 'misc'
NER = 'ner'
START_CHAR = 'start_char'
END_CHAR = 'end_char'
FIELD_TO_IDX = {ID: 0, TEXT: 1, LEMMA: 2, UPOS: 3, XPOS: 4, FEATS: 5, HEAD: 6, DEPREL: 7, DEPS: 8, MISC: 9}


def convert_token_dict_ner(token_dict):
        """ Convert the dictionary format input token to the CoNLL-U format output token. This is the reverse function of
        `convert_conll_token`.
        Input: dictionary format token, which is a dictionaries for the token.
        Output: CoNLL-U format token, which is a list for the token.
        """
        token_conll = ['_' for i in range(FIELD_NUM)]
        misc = []
        for key in token_dict:
            if key == NER:
                misc.append("{}={}".format(key, token_dict[key]))
            elif key == MISC:
                # avoid appending a blank misc entry.
                # otherwise the resulting misc field in the conll doc will wind up being blank text
                if token_dict[key]:
                    misc.append(token_dict[key])
            elif key == ID:
                token_conll[FIELD_TO_IDX[key]] = '-'.join([str(x) for x in token_dict[key]]) if isinstance(token_dict[key], tuple) else str(token_dict[key])
            elif key in FIELD_TO_IDX:
                token_conll[FIELD_TO_IDX[key]] = str(token_dict[key])
        if misc:
            token_conll[FIELD_TO_IDX[MISC]] = "|".join(misc)
        else:
            token_conll[FIELD_TO_IDX[MISC]] = '_'
        # when a word (not mwt token) without head is found, we insert dummy head as required by the UD eval script
        if '-' not in token_conll[FIELD_TO_IDX[ID]] and HEAD not in token_dict:
            token_conll[FIELD_TO_IDX[HEAD]] = str(int(token_dict[ID] if isinstance(token_dict[ID], int) else token_dict[ID][0]) - 1) # evaluation script requires head: int
        return token_conll

def doc2conllner(doc):
    """ Convert a Document object to a list of list of strings
    Each sentence is represented by a list of strings: first the comments, then the converted tokens
    """
    doc_conll = []
    for sentence in doc.sentences:
        sent_id = "# sent_id = "+NEWDOC+"-"+str(sentence._id)
        sent_conll = list()
        sent_conll.append(sent_id)
        if not sentence._comments:
            sentence._comments = "# text = \"\""
        sent_conll.append(sentence.comments)
        for token_dict in sentence.to_dict():
            token_conll = convert_token_dict_ner(token_dict)
            sent_conll.append("\t".join(token_conll))
        doc_conll.append(sent_conll)
    return doc_conll

def doc2conllner_text(doc):
    """ Convert a Document to a big block of text.
    """
    doc_conll = doc2conllner(doc)
    return "\n\n".join("\n".join(line for line in sentence)
        for sentence in doc_conll) + "\n\n"

def write_doc2conllner(doc, filename):
    """ Writes the doc as a conll file to the given filename
    """
    with open(filename, 'w', encoding='utf-8') as outfile:
        outfile.write("# newdoc = "+NEWDOC+"\n")
        outfile.write(doc2conllner_text(doc))

import unicodedata, re

all_chars = (unichr(i) for i in range(0x110000))
control_chars = ''.join(map(chr, list(range(0,32)) + list(range(127,160))))

control_char_re = re.compile('[%s]' % re.escape(control_chars))

def sanitize(s):
    return unicodedata.normalize('NFC', control_char_re.sub(' ', s))


def preparetext(file_content):
    '''Clean up nasty characters'''
    output=sanitize(re.sub(r'(?m)^\@.*\n?',' ',file_content.replace('’', '\'').replace('‘', '\'')).replace('…',' ... ').replace('«',' " ').replace('»',' " ').replace('<BLOCK>',' ').replace('“',' " ').replace('„',' " ').replace('* * *',' . ').replace('‚','\'').replace('‫','').replace('‬',''))
    return output



def preparenlp(model):
    try: 
        nlp = stanza.Pipeline(lang=model, logging_level="DEBUG", processors=args.processors)
    except:
        print(model+" not found. I'll try to download it...")
        stanza.download(model)
        nlp = stanza.Pipeline(lang=model, logging_level="DEBUG", processors=args.processors)
    return nlp


def udparser(nlp,text,filename):
    doc = nlp(text)
    conllufile = args.target+seppath+Path(filename).stem+".conllu"
    if stanza.__version__ <= "1.3.0":
        write_doc2conllner(doc,conllufile)
    else:
        CoNLL.write_doc2conll(doc,conllufile)
        


def main():
    global debug
    global args
    global seppath
    global ud
    global NEWDOC
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
    for filename in sorted(glob.glob(args.source+seppath+'*.txt')):
        file_content = open(filename, encoding='utf-8').read()
        print("Reading: "+filename)
        NEWDOC = Path(filename).stem.split('.')[0]
        metafile= open(args.metadata+seppath+Path(filename).stem+".metadata","w+")
        '''Extract metadata'''
        header = re.findall(r'@.*',file_content)
        try:
            header.remove('@endheader')
        except:
            pass
        metadata= open(args.metadata+Path(filename).stem+".metadata","w+")
        if header: 
            title=Path(filename).stem.split("_")[0]
            metadata.write("<text id=\""+title+"\" ")
            for feature in header:
                value = feature.split('=')
                try:
                    metadata.write(re.sub('^@','',value[0].strip())+"=\""+value[1].strip()+"\" ")
                except:
                    pass
        else:
            '''or extract metadata from filename...'''
            lang=Path(filename).stem.split("_")[1]
            title=Path(filename).stem.split("_")[0]
            metadata.write("<text id=\""+title+"\" ")
            metadata.write("origtitle=\""+title+"\" language=\""+lang+"\" ")
        metadata.write(">")
        metadata.close()
        text=preparetext(file_content)
        print("Starting parser...")
        udparser(nlp,text,filename)
    print("--- %s seconds ---" % (time.time() - start_time))
    print("Done! Happy corpus-based typological linguistics!\n")

if __name__ == "__main__":
    main()
    sys.exit(0)

