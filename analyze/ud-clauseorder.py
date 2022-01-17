############ This script prints out comma-separated spreadsheet(s) (report-language.csv) with the ratio of word order pairs in conllu files ########
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
import io
import conllu

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

USAGE = './ud-clauseorder.py <source_directory> <target_directory> [-h] \n [--analyze csubj|xcomp|ccomp|advcl|acl]'

def build_parser():

    parser = argparse.ArgumentParser(description='ud-wordorder: Extract sentence/clause frequency')


    parser.add_argument('source',help='Source for conllu files, must be dir/dir/dir')
    parser.add_argument('target',help='Target destination for csv files')
    parser.add_argument('-a', '--analyze', nargs='*', help=' Extract word-order pairs frequency: specify UD syntactic relation')

    return parser


def check_args(args):
    '''Exit if required arguments not specified'''
    check_flags = {}

def udanalyzer(conllufile,countwriter):
    data = open(conllufile, mode="r", encoding="utf-8")
    sentences = conllu.parse_tree(data.read())
    length = sum(1 for x in sentences)
    for root in sentences:
        print("Analyzing sentence "+root.metadata["sent_id"])
        mcOrder = None
        csubj = None
        cobj = None
        msubj = None
        mobj = None
        mcleft = {}
        mcright = {}
        mleftobj = {}
        mrightobj = {}
        cleftobj = {}
        crightobj = {}
        mleftsubj = {}
        mrightsubj = {}
        cleftsubj = {}
        crightsubj = {}


        for token in root.children:
                 #Collect main argument order
                if token.token["deprel"] not in mleftsubj:
                        mleftsubj[token.token["deprel"]] = {}
                if token.token["deprel"] not in mrightsubj:
                        mrightsubj[token.token["deprel"]] = {}
                if token.token["deprel"] not in mleftobj:
                        mleftobj[token.token["deprel"]] = {}
                if token.token["deprel"] not in mrightobj:
                        mrightobj[token.token["deprel"]] = {}
                #Collect OV order for main
                if token.token["deprel"] in subj:
                    if int(token.token["id"]) < int(root.token["id"]):
                            mleftsubj[token.token["deprel"]][token.token["id"]]= token
                    if int(token.token["id"]) > int(root.token["id"]):
                            mrightsubj[token.token["deprel"]][token.token["id"]]= token
                #Collect OV order for main
                if token.token["deprel"] in obj:
                    if int(token.token["id"]) > int(root.token["id"]):
                            mleftobj[token.token["deprel"]][token.token["id"]]= token
                    if int(token.token["id"]) < int(root.token["id"]):
                            mrightobj[token.token["deprel"]][token.token["id"]]= token
                if token.token["deprel"] in args.analyze:
                #Collect main-clause order
                    if token.token["deprel"] not in mcleft:
                        mcleft[token.token["deprel"]] = {}
                    if token.token["deprel"] not in mcright:
                        mcright[token.token["deprel"]] = {}
                    #main is on the left
                    if int(token.token["id"]) > int(root.token["id"]):
                        #collect token
                        mcleft[token.token["deprel"]][token.token["id"]]= token
                    #main is on the right
                    if int(token.token["id"]) < int(root.token["id"]):
                    #collect token
                        mcright[token.token["deprel"]][token.token["id"]]= token
                    
                    #Children level
                    for child in token.children:
                        if child.token["deprel"] not in cleftsubj:
                            cleftsubj[child.token["deprel"]] = {}
                        if child.token["deprel"] not in crightsubj:
                            crightsubj[child.token["deprel"]] = {}
                        if child.token["deprel"] not in cleftobj:
                            cleftobj[child.token["deprel"]] = {}
                        if child.token["deprel"] not in crightobj:
                            crightobj[child.token["deprel"]] = {}

                        #Collect SV for clause
                        if child.token["deprel"] in subj:
                            if int(child.token["id"]) < int(token.token["id"]):
                                cleftsubj[child.token["deprel"]][child.token["id"]]= child
                            if int(child.token["id"]) > int(token.token["id"]):
                                crightsubj[child.token["deprel"]][child.token["id"]]= child
                        #Collect OV order for clause
                        if child.token["deprel"] in obj:
                            if int(child.token["id"]) > int(token.token["id"]):
                                cleftobj[child.token["deprel"]][child.token["id"]]= child
                            if int(child.token["id"]) < int(token.token["id"]):
                                crightobj[child.token["deprel"]][child.token["id"]]= child

        #MC-order
        for syntacticrel in args.analyze:
            if syntacticrel in mcleft:
                for ident,token in mcleft[syntacticrel].items():
                    if token.token["head"] == root.token["id"]:
                            head = root
                    mcLength = abs(int(token.token["id"])-int(root.token["id"]))
                    mcOrder = 'main-'+syntacticrel
            if syntacticrel in mcright:
                for ident,token in mcright[syntacticrel].items():
                    if token.token["head"] == root.token["id"]:
                            head = root
                    mcLength = abs(int(token.token["id"])-int(root.token["id"]))
                    mcOrder = syntacticrel+'-main'

        #SV-main
        for sv in subj:
            if sv in mleftsubj:
                for ident,token in mleftsubj[sv].items():
                    msubj = sv+'-V'
            if sv in mrightsubj:
                for ident,token in mrightsubj[sv].items():
                    msubj = 'V-'+sv
        #VO-main
        for vo in obj:
            if vo in mleftobj:
                for ident,token in mleftobj[vo].items():
                    mobj = 'V-'+vo
            if vo in mrightobj:
                for ident,token in mrightobj[vo].items():
                    mobj = vo+'-V'
        #SV-clause
        for sv in subj:
            if sv in cleftsubj:
                for ident,token in cleftsubj[sv].items():
                    csubj = sv+'-V'
            if sv in crightsubj:
                for ident,token in crightsubj[sv].items():
                    csubj = 'V-'+sv
        #VO-clause
        for vo in obj:
            if vo in cleftobj:
                for ident,token in cleftobj[vo].items():
                    cobj = 'V-'+vo
            if vo in crightobj:
                for ident,token in crightobj[vo].items():
                    cobj = vo+'-V'

        #Write table: 
        if mcOrder is None:
            print("Sentence does not contain clauses")
        else:
            countwriter.writerow([mcOrder,msubj,mobj,csubj,cobj,mcLength,conllufile.split('/')[3].split('.')[0]+"-"+root.metadata["sent_id"]])


def main():
    global debug
    global args
    global seppath
    global subj
    global obj
    subj = ["nsubj","nsubj:advmod", "nsubj:caus", "nsubj:cleft", "nsubj:cop","nsubj:lvc","nsubj:pass"]
    obj = ["obj","obj:advmod","obj:advneg","obj:agent", "obj:lvc","obj:obl"]
    parser = build_parser()
    args = parser.parse_args()
    seppath = '/'
    '''Check arguments'''    
    if check_args(args) is False:
     sys.stderr.write("There was a problem validating the arguments supplied. Please check your input and try again. Exiting...\n")
     sys.exit(1)
    '''Unknown function, I'll check it later''' 
    start_time = time.time()
    csvfile = open(args.target+"/report-"+args.source.split(seppath)[2]+".csv", 'a+', newline='',encoding='utf-8')    
    countwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
    countwriter.writerow(['main-clause_Order', 'main_SV', 'main_VO', 'clause_SV', 'clause_VO', 'main-clause_Length', 'sentence'])
    for conllufile in sorted(glob.glob(args.source+'/*.conllu')):
        udanalyzer(conllufile,countwriter)
        print("Done with "+conllufile)
    print("--- %s seconds ---" % (time.time() - start_time))
    print("Done! Happy corpus-based typological linguistics!\n")

if __name__ == "__main__":
    main()
    sys.exit(0)

