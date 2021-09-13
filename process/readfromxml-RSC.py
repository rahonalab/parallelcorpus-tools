#!/usr/bin/env python3
import sys
import subprocess
import re
import glob
from pathlib import Path
from tqdm import tqdm
import os


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

USAGE = './readfromxml-RSC.py -f file -m path_to_metadata'

def build_parser():

    parser = argparse.ArgumentParser(description='clean raw txt and extract metadata')
    parser.add_argument('-f', dest="filename", required=True, help='file')
    parser.add_argument('-m', dest="metadata", required=True, help='path_to_metadata')    
    
    return parser

import unicodedata, re
import xml.etree.cElementTree as ET


all_chars = (unichr(i) for i in range(0x110000))
control_chars = ''.join(map(chr, list(range(0,32)) + list(range(127,160))))

control_char_re = re.compile('[%s]' % re.escape(control_chars))

def sanitize(s):
    return unicodedata.normalize('NFC', control_char_re.sub(' ', s))


def sentencesplit(file_content):
    file_content = re.sub(r'<page.*?>|</page.*?>|<normalised.*?>|</normalised.*?>', '', file_content)
    file_content = os.linesep.join([s for s in file_content.splitlines() if s])   
    root = ET.fromstring(file_content)
    #Child must be <s>...</s>
    for child in root:
        print(child.text)
    #Write metadata
    metadata= open(args.metadata+Path(args.filename).stem+".metadata","w+")
    metadata.write("<text ")
    for k,v in root.attrib.items():
        metadata.write(k+'="'+v+'" ')
    metadata.write(">\n")

def main():
    global debug
    parser = build_parser()
    global args
    args = parser.parse_args()
    '''Check arguments'''    
    if check_args(args) is False:
     sys.stderr.write("There was a problem validating the arguments supplied. Please check your input and try again. Exiting...\n")
     sys.exit(1)

    '''Unknown function, I'll check it later''' 
    start_time = time.time()
    file_content = open(args.filename).read()
    sentencesplit(file_content)

def check_args(args):
    '''Exit if required arguments not specified'''
    check_flags = {}

def exec_command(command):
    """Execute command.
       Return a tuple: returncode, output and error message(None if no error).
    """
    sub_p = subprocess.Popen(command,
                             shell=True,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
    output, err_msg = sub_p.communicate()
    return (sub_p.returncode, output, err_msg)


if __name__ == "__main__":
    main()
    sys.exit(0)

