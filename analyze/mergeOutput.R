library("reshape2")
library("tidyverse")
library("entropy")
setwd("/Users/utw/Desktop/linguistics/saarbruecken/papers/paper1/paper1/data")
dependencies = list("acl","amod","det","case")
languages <- c("Danish","Dutch","English","French","German","Greek","Italian","Polish","Portuguese","Spanish","Welsh")
#Create shorter df
df <- setNames(data.frame(matrix(ncol = 16, nrow = 0)), c("language", "source", "dependency", "raw_entropy", "hraw_mpos_entropy", "hpos_mraw_entropy", "hpos_mpos_entropy",  "art_hraw_mlemma_entropy","art_hpos_mlemma_entropy", "art_hpos_mposlemma_entropy","dem_hraw_mlemma_entropy", "dem_hpos_mlemma_entropy",  "dem_hpos_mposlemma_entropy","case_hraw_mlemma_entropy", "case_hpos_mlemma_entropy",  "case_hpos_mposlemma_entropy"))
#Process csv files
for (i in list.files()) {
	out <- read.csv(i,sep=',',quote='"')
#Calculate grand total for sub-dependencies
for (dep in dependencies) {
	for (lang in languages) {
	raw_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$raw_modx)
	raw_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$raw_xmod)
	hraw_mpos_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hraw_mpos_modx)
	hraw_mpos_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hraw_mpos_xmod)
	hpos_mraw_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hpos_mraw_modx)
	hpos_mraw_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hpos_mraw_xmod)
	hpos_mpos_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hpos_mpos_modx)
	hpos_mpos_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$hpos_mpos_xmod)
	art_hraw_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hraw_mlemma_modx)
	art_hraw_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hraw_mlemma_xmod)
	art_hpos_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hpos_mlemma_modx)
	art_hpos_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hpos_mlemma_xmod)
	art_hpos_mposlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hpos_mposlemma_modx)
	art_hpos_mposlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$art_hpos_mposlemma_xmod)
	dem_hraw_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hraw_mlemma_modx)
	dem_hraw_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hraw_mlemma_xmod)
	dem_hpos_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hpos_mlemma_modx)
	dem_hpos_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hpos_mlemma_xmod)
	dem_hpos_mposlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hpos_mposlemma_modx)
	dem_hpos_mposlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$dem_hpos_mposlemma_xmod)
	case_hraw_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hraw_mlemma_modx)
	case_hraw_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hraw_mlemma_xmod)
	case_hpos_mlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hpos_mlemma_modx)
	case_hpos_mlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hpos_mlemma_xmod)
	case_hpos_mposlemma_modx =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hpos_mposlemma_modx)
	case_hpos_mposlemma_xmod =	sum(out[ which(grepl(lang,out$language) & grepl(dep,out$dependency)),]$case_hpos_mposlemma_xmod)




	raw_entropy = entropy(c(raw_xmod,raw_modx), method="ML", unit="log2")
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
	art_hraw_mlemma_entropy = entropy(c(art_hraw_mlemma_xmod,art_hraw_mlemma_modx), method="ML", unit="log2")
	art_hpos_mlemma_entropy = entropy(c(art_hpos_mlemma_xmod,art_hpos_mlemma_modx), method="ML", unit="log2")
	art_hpos_mposlemma_entropy = entropy(c(art_hpos_mposlemma_xmod,art_hpos_mposlemma_modx), method="ML", unit="log2")

	dem_hraw_mlemma_entropy = entropy(c(dem_hraw_mlemma_xmod,dem_hraw_mlemma_modx), method="ML", unit="log2")
	dem_hpos_mlemma_entropy = entropy(c(dem_hpos_mlemma_xmod,dem_hpos_mlemma_modx), method="ML", unit="log2")
	dem_hpos_mposlemma_entropy = entropy(c(dem_hpos_mposlemma_xmod,dem_hpos_mposlemma_modx), method="ML", unit="log2")

	case_hraw_mlemma_entropy = entropy(c(case_hraw_mlemma_xmod,case_hraw_mlemma_modx), method="ML", unit="log2")
	case_hpos_mlemma_entropy = entropy(c(case_hpos_mlemma_xmod,case_hpos_mlemma_modx), method="ML", unit="log2")
	case_hpos_mposlemma_entropy = entropy(c(case_hpos_mposlemma_xmod,case_hpos_mposlemma_modx), method="ML", unit="log2")

	
	row <- data.frame(language=lang,source=basename(i),dependency=paste(dep,"*",sep=":"),raw_entropy=raw_entropy, hraw_mpos_entropy=hraw_mpos_entropy, hpos_mraw_entropy=hpos_mraw_entropy, hpos_mpos_entropy=hpos_mpos_entropy, art_hraw_mlemma_entropy=art_hraw_mlemma_entropy, art_hpos_mlemma_entropy=art_hpos_mlemma_entropy,  art_hpos_mposlemma_entropy=art_hpos_mposlemma_entropy,dem_hraw_mlemma_entropy=dem_hraw_mlemma_entropy,dem_hpos_mlemma_entropy=dem_hpos_mlemma_entropy,  dem_hpos_mposlemma_entropy=dem_hpos_mposlemma_entropy,case_hraw_mlemma_entropy=case_hraw_mlemma_entropy, case_hpos_mlemma_entropy=case_hpos_mlemma_entropy,  case_hpos_mposlemma_entropy=case_hpos_mposlemma_entropy)
	df <- rbind(df,row)
	}		
	}	
#Add data from output files, with just 16 columns
out <- within(out, source <- basename(i))
df <- rbind(df,select(out,"language", "source", "dependency", "raw_entropy", "hraw_mpos_entropy", "hpos_mraw_entropy", "hpos_mpos_entropy",  "art_hraw_mlemma_entropy","art_hpos_mlemma_entropy", "art_hpos_mposlemma_entropy","dem_hraw_mlemma_entropy", "dem_hpos_mlemma_entropy",  "dem_hpos_mposlemma_entropy","case_hraw_mlemma_entropy", "case_hpos_mlemma_entropy",  "case_hpos_mposlemma_entropy"))
}

for (lang in languages) {
	df <- within(df, language[grepl(lang,language)] <- lang )
}

write.csv(x=df,file="../output-all-ciep.csv",row.names = FALSE)

