library("plyr")
library("tidyverse")
#Dependency list
clauses = list("acl","csubj","ccomp","xcomp","advcl")
subjects = list("nsubj","nsubj:advmod", "nsubj:caus", "nsubj:cleft", "nsubj:cop","nsubj:lvc","nsubj:pass")

df <- setNames(data.frame(matrix(ncol = 56, nrow = 0)), c("language", "source", "clause-type", "main-clause", "clause-main","VS-clause","SV-clause", "nullsubj-clause", "VO-clause","OV-clause", "nullobj-clause"))

setwd("~/Desktop/linguistics/saarbruecken/parallelcorpusbuilding/output/iker-sle2022")


for (filename in list.files()) {
	report <- read.csv(filename,sep=',',quote='"')
	language = str_split(str_remove(basename(filename[1]),"report-")[1],"[.]")[[1]][1]
	source = basename(filename)
	size = unique(report$size)
	no_sent = sum(as.integer(size[!size %in% "size"]))

	for (clause in clauses) {
		mainc = paste("main", clause, sep="-")
		cmain = paste(clause, "main", sep="-")
		#Clause types
		mainclause = nrow(report[ which(report$main.clause_Order==mainc),])
		clausemain = nrow(report[ which(report$main.clause_Order==cmain),])
	

	#Clause argument
	svclause = nrow(report[ which((report$clause_SV=="nsubj-V" | report$clause_SV=="nsubj:pass-V") & (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])
	vsclause = nrow(report[ which((report$clause_SV=="V-nsubj" | report$clause_SV=="V-nsubj:pass")& (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])
	nullsubjclause = nrow(report[ which((report$clause_SV== "") & (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])

	ovclause = nrow(report[ which((report$clause_VO=="obj-V") & (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])
	voclause = nrow(report[ which((report$clause_VO=="V-obj") & (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])
	nullobjclause = nrow(report[ which((report$clause_VO== "") & (report$main.clause_Order==mainc | report$main.clause_Order==cmain)),])

	
	
	row <- data.frame (language = language, source = source, clausetype = clause, mainclause = mainclause, clausemain = clausemain, vsclause = vsclause, svclause = svclause, nullsubjclause = nullsubjclause, voclause = voclause, ovclause = ovclause, nullobjclause = nullobjclause)
	df <- rbind(df, row)		}
}

write.csv(x=df,file="../output-ciep-clause.csv",row.names = FALSE)
