# Tools for process and analyze (parallel) corpora. See pipeline files for more information
## process/
* readfromxml-{CORPUS}.py: read text from xml files (several corpora)
* readfromraw-CIEP.py: read text from raw txt files (CIEP corpus)
* conllu2vrt.py: transform conllu files into verticalized xml files ready for cwb-encode
* ud-ciep.py: Parse CIEP corpus into treebanks (spacy_udpipe -> conllufile) and analyze it for word order (pyconllu > csv files). (outdated)
## analyze/
* ud-worder.py: collect word-order pairs from conllu files (CIEP corpus, other corpora?)
* readReport.R: Rscript to read ud-worder.py reports into csv files
* mergeOutput.R: Rscript to process readReport.R output
