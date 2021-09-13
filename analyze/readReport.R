library("entropy")
library("plyr")
library("tidyverse")
#Dependency list
dependencies = list("acl","acl:relcl","amod","case","case:pred","det","det:poss","det:numgov","det:nummod","det:predet", "nummod", "nummod:gov")
#Article and demonstrative
article = list()
demonstrative = list()

article[["Danish"]] = list("en", "et")
article[["Dutch"]] = list("de", "het", "een")
article[["English"]] = list("the", "a")
article[["German"]] = list("der", "ein")
article[["French"]] = list("le", "un")
article[["Greek"]] = list("ο", "ένας")
article[["Irish"]] = list("an","na","An","Na","AN","NA")
article[["Italian"]] = list("il", "uno")
article[["Polish"]] = NA
article[["Portuguese"]] = list("o", "um","O","Um","UM")
article[["Russian"]] = NA
article[["Serbian-Croatian-Bosnian"]] = NA
article[["Spanish"]] = list("el", "uno")
article[["Welsh"]] = list("y","Υ")

demonstrative[["Danish"]] = list("denne", "dette", "disse", "den", "det", "de")
demonstrative[["Dutch"]] = list("die", "dit", "dat", "deze")
demonstrative[["English"]] = list("this", "that")
demonstrative[["German"]] = list("dies")
demonstrative[["French"]] = list("ce")
demonstrative[["Greek"]] = list("αυτός", "εκείνος", "τούτος", "αυτά", "αυτές", "αυτή", "αυτήν", "αυτής", "αυτό", "αυτοί", "αυτόν", "αυτός", "αυτού", "αυτούς", "αυτών", "εκείνα", "εκείνες", "εκείνη", "εκείνο", "εκείνοι", "εκείνον", "εκείνος", "εκείνου", "εκείνους", "εκείνων", "τούτη", "τούτο", "τούτον", "τούτους","Αυτός", "Εκείνος", "Τούτος", "Αυτά", "Αυτές", "Αυτή", "Αυτήν", "Αυτής", "Αυτό", "Αυτοί", "Αυτόν", "Αυτός", "Αυτού", "Αυτούς", "Αυτών", "Εκείνα", "Εκείνες", "Εκείνη", "Εκείνο", "Εκείνοι", "Εκείνον", "Εκείνος", "Εκείνου", "Εκείνους", "Εκείνων", "Τούτη", "Τούτο", "Τούτον", "Τούτους")
demonstrative[["Irish"]] = list("seo", "so","sin","siúd","súd","Seo", "So","Sin","Siúd","Súd","san","Shin","shin")
demonstrative[["Italian"]] = list("questo", "quello", "codesto")
demonstrative[["Polish"]] = list("ów", "ten")
demonstrative[["Portuguese"]] = list("este", "esse", "aquele", "esta", "essa", "aquela", "estes", "esses", "aqueles", "estas", "essas", "aquelas","Este", "Esse", "Aquele", "Esta", "Essa", "Aquela", "Estes", "Esses", "Aqueles", "Estas", "Essas", "Aquelas")
demonstrative[["Russian"]] = list("этот","тот")
demonstrative[["Serbian-Croatian-Bosnian"]] = list("ovaj","taj","onaj")
demonstrative[["Spanish"]] = list("este", "ese", "aquel")
demonstrative[["Welsh"]] = list("hwn", "hwnnw", "hon", "honno", "hyn", "hynny","Ηwn", "Ηwnnw", "Ηon", "Ηonno", "Ηyn", "Ηynny")

#Go through list of adposition
setwd("~/Desktop/linguistics/saarbruecken/parallelcorpusbuilding/lemmas/adpositions/")
adposition = list()
for (filename in list.files()) {
adp <- read.csv(filename,sep=',')
language = str_remove(basename(filename),".csv")
adposition[[language]] <- adp[which(adp$adp == "1"),]$lemma
}

df <- setNames(data.frame(matrix(ncol = 56, nrow = 0)), c("language", "source", "no_sent", "dependency", "raw_modx", "raw_xmod", "raw_frequency", "raw_entropy", "hraw_mpos_modx", "hraw_mpos_xmod", "hraw_mpos_frequency", "hraw_mpos_entropy", "hpos_mraw_modx", "hpos_mraw_xmod", "hpos_mraw_frequency", "hpos_mraw_entropy","hpos_mpos_modx", "hpos_mpos_xmod", "hpos_mpos_frequency", "hpos_mpos_entropy","art_hraw_mlemma_modx", "art_hraw_mlemma_xmod", "art_hraw_mlemma_frequency", "art_hraw_mlemma_entropy", "art_hpos_mlemma_modx",	"art_hpos_mlemma_xmod", "art_hpos_mlemma_frequency", "art_hpos_mlemma_entropy", "art_hpos_mposlemma_modx", "art_hpos_mposlemma_xmod", "art_hpos_mposlemma_frequency", "art_hpos_mposlemma_entropy", "dem_hraw_mlemma_modx", "dem_hraw_mlemma_xmod", "dem_hraw_mlemma_frequency", "dem_hraw_mlemma_entropy", "dem_hpos_mlemma_modx",	"dem_hpos_mlemma_xmod", "dem_hpos_mlemma_frequency", "dem_hpos_mlemma_entropy", "dem_hpos_mposlemma_modx", "dem_hpos_mposlemma_xmod", "dem_hpos_mposlemma_frequency", "dem_hpos_mposlemma_entropy", "case_hraw_mlemma_modx", "case_hraw_mlemma_xmod", "case_hraw_mlemma_frequency", "case_hraw_mlemma_entropy", "case_hpos_mlemma_modx",	"case_hpos_mlemma_xmod", "case_hpos_mlemma_frequency", "case_hpos_mlemma_entropy", "case_hpos_mposlemma_modx", "case_hpos_mposlemma_xmod", "case_hpos_mposlemma_frequency", "case_hpos_mposlemma_entropy"))

setwd("~/Desktop/linguistics/saarbruecken/parallelcorpusbuilding/output/bertinoro/")

for (dep in dependencies) {
	xmod = paste("X", dep, sep="-")
	modx = paste(dep, "X", sep="-")
	for (filename in list.files()) {
	report <- read.csv(filename,sep=',',quote='"')
	language = str_split(str_remove(basename(filename[1]),"report-")[1],"[.]")[[1]][1]
	source = basename(filename)
	size = unique(report$size)
	no_sent = sum(as.integer(size[!size %in% "size"]))

	art_hpos_mlemma_modx = NA
	art_hpos_mlemma_xmod = NA
	art_hpos_mlemma_entropy = NA
	art_hraw_mlemma_modx = NA
	art_hraw_mlemma_xmod = NA
	art_hraw_mlemma_entropy = NA
	art_hpos_mposlemma_modx = NA
	art_hpos_mposlemma_xmod = NA
	art_hpos_mposlemma_entropy = NA

	dem_hpos_mlemma_modx = NA
	dem_hpos_mlemma_xmod = NA
	dem_hpos_mlemma_entropy = NA
	dem_hraw_mlemma_modx = NA
	dem_hraw_mlemma_xmod = NA
	dem_hraw_mlemma_entropy = NA
	dem_hpos_mposlemma_modx = NA
	dem_hpos_mposlemma_xmod = NA
	dem_hpos_mposlemma_entropy = NA

	case_hpos_mlemma_modx = NA
	case_hpos_mlemma_xmod = NA
	case_hpos_mlemma_entropy = NA
	case_hraw_mlemma_modx = NA
	case_hraw_mlemma_xmod = NA
	case_hraw_mlemma_entropy = NA
	case_hpos_mposlemma_modx = NA
	case_hpos_mposlemma_xmod = NA
	case_hpos_mposlemma_entropy = NA




	#No filters
	raw_xmod = nrow(report[ which(report$order==xmod),])
	raw_modx = nrow(report[ which(report$order==modx),])
	raw_entropy = entropy(c(raw_xmod,raw_modx), method="ML", unit="log2")
	
	
	#Pos filters
	if (startsWith(dep,"amod")) {
	#h-raw_m-pos
	hraw_mpos_xmod = nrow(report[ which(report$order==xmod & report$upossecond == "ADJ"),])
	hraw_mpos_modx = nrow(report[ which(report$order==modx & report$uposfirst == "ADJ"),])	
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	#h-pos_m-raw	
	hpos_mraw_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN")),])
	hpos_mraw_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN")),])	
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	#h-pos_m-pos
	hpos_mpos_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & report$upossecond == "ADJ"),])
	hpos_mpos_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & report$uposfirst == "ADJ"),])	
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
			}
	
	#Pos filters
	if (startsWith(dep,"nummod")) {
	#h-raw_m-pos
	hraw_mpos_xmod = nrow(report[ which(report$order==xmod & report$upossecond == "NUM"),])
	hraw_mpos_modx = nrow(report[ which(report$order==modx & report$uposfirst == "NUM"),])	
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	#h-pos_m-raw	
	hpos_mraw_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN")),])
	hpos_mraw_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN")),])	
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	#h-pos_m-pos
	hpos_mpos_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & report$upossecond == "NUM"),])
	hpos_mpos_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & report$uposfirst == "NUM"),])	
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
			}

	
	#Pos filters
	if (startsWith(dep,"det")) {
	#h-raw_m-pos
	hraw_mpos_xmod = nrow(report[ which(report$order==xmod & (report$upossecond == "DET" | report$upossecond == "PRON")),])
	hraw_mpos_modx = nrow(report[ which(report$order==modx & (report$uposfirst == "DET" | report$uposfirst == "PRON")),])	
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	#h-pos_m-raw	
	hpos_mraw_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN")),])
	hpos_mraw_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN")),])	
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	#h-pos_m-pos
	hpos_mpos_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$upossecond == "DET" | report$upossecond == "PRON" )),])
	hpos_mpos_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "DET" | report$uposfirst == "PRON" )),])	
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
	#if Portuguese or Greek or Welsh or Irish, check tokens instead of lemmas
	if (language == "Portuguese" | language == "Greek" | language == "Welsh" | language == "Irish") {
	#dem_hraw_mlemma
	dem_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$tokensecond %in% demonstrative[[language]])),])
	dem_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$tokenfirst %in% demonstrative[[language]])),])
	dem_hraw_mlemma_entropy = entropy(c(dem_hraw_mlemma_xmod,dem_hraw_mlemma_modx), method="ML", unit="log2")
	#dem_hpos_mlemma
	dem_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$tokensecond %in% demonstrative[[language]])),])
	dem_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$tokenfirst %in% demonstrative[[language]])),])
	dem_hpos_mlemma_entropy = entropy(c(dem_hpos_mlemma_xmod,dem_hpos_mlemma_modx), method="ML", unit="log2")
	#dem_hpos_mposlemma
	dem_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "DET" | report$upossecond == "PRON" ) & (report$tokensecond %in% demonstrative[[language]])),])
	dem_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "DET" | report$uposfirst == "PRON" ) & (report$tokenfirst %in% demonstrative[[language]])),])
	dem_hpos_mposlemma_entropy = entropy(c(dem_hpos_mposlemma_xmod,dem_hpos_mposlemma_modx), method="ML", unit="log2")
	#art_hraw_mlemma
	art_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$tokensecond %in% article[[language]])),])
	art_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$tokenfirst %in% article[[language]])),])
	art_hraw_mlemma_entropy = entropy(c(art_hraw_mlemma_xmod,art_hraw_mlemma_modx), method="ML", unit="log2")
	#art_hpos_mlemma
	art_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$tokensecond %in% article[[language]])),])
	art_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$tokenfirst %in% article[[language]])),])
	art_hpos_mlemma_entropy = entropy(c(art_hpos_mlemma_xmod,art_hpos_mlemma_modx), method="ML", unit="log2")
	#art_hpos_mposlemma
	art_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "DET" | report$upossecond == "PRON" ) & (report$tokensecond %in% article[[language]])),])
	art_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "DET" | report$uposfirst == "PRON" ) & (report$tokenfirst %in% article[[language]])),])
	art_hpos_mposlemma_entropy = entropy(c(art_hpos_mposlemma_xmod,art_hpos_mposlemma_modx), method="ML", unit="log2")
	}
	else {
	print(language)		
	#dem_hraw_mlemma
	dem_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$lemmasecond %in% demonstrative[[language]])),])
	dem_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$lemmafirst %in% demonstrative[[language]])),])
	dem_hraw_mlemma_entropy = entropy(c(dem_hraw_mlemma_xmod,dem_hraw_mlemma_modx), method="ML", unit="log2")
	#dem_hpos_mlemma
	dem_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$lemmasecond %in% demonstrative[[language]])),])
	dem_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$lemmafirst %in% demonstrative[[language]])),])
	dem_hpos_mlemma_entropy = entropy(c(dem_hpos_mlemma_xmod,dem_hpos_mlemma_modx), method="ML", unit="log2")
	#dem_hpos_mposlemma
	dem_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "DET" | report$upossecond == "PRON" ) & (report$lemmasecond %in% demonstrative[[language]])),])
	dem_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "DET" | report$uposfirst == "PRON" ) & (report$lemmafirst %in% demonstrative[[language]])),])
	dem_hpos_mposlemma_entropy = entropy(c(dem_hpos_mposlemma_xmod,dem_hpos_mposlemma_modx), method="ML", unit="log2")
	#art_hraw_mlemma
	art_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$lemmasecond %in% article[[language]])),])
	art_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$lemmafirst %in% article[[language]])),])
	art_hraw_mlemma_entropy = entropy(c(art_hraw_mlemma_xmod,art_hraw_mlemma_modx), method="ML", unit="log2")
	#art_hpos_mlemma
	art_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$lemmasecond %in% article[[language]])),])
	art_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$lemmafirst %in% article[[language]])),])
	art_hpos_mlemma_entropy = entropy(c(art_hpos_mlemma_xmod,art_hpos_mlemma_modx), method="ML", unit="log2")
	#art_hpos_mposlemma
	art_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "DET" | report$upossecond == "PRON" ) & (report$lemmasecond %in% article[[language]])),])
	art_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "DET" | report$uposfirst == "PRON" ) & (report$lemmafirst %in% article[[language]])),])
	art_hpos_mposlemma_entropy = entropy(c(art_hpos_mposlemma_xmod,art_hpos_mposlemma_modx), method="ML", unit="log2")
	}
	}
	
	#Pos filters
	if (startsWith(dep,"case")) {
	#h-raw_m-pos
	hraw_mpos_xmod = nrow(report[ which(report$order==xmod & report$upossecond == "ADP"),])
	hraw_mpos_modx = nrow(report[ which(report$order==modx & report$uposfirst == "ADP"),])	
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	#h-pos_m-raw	
	hpos_mraw_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN")),])
	hpos_mraw_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN")),])	
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	#h-pos_m-pos
	hpos_mpos_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & report$upossecond == "ADP"),])
	hpos_mpos_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & report$uposfirst == "ADP"),])	
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
	#Check if adposition list exists
	if (is.null(adposition[[language]])) {
	adposition[[language]] = NA
		}
	#If Portuguese we check the tokens
	if (language == "Portuguese") {
	print(language)
	#case_hraw_mlemma
	case_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$tokensecond %in% adposition[[language]])),])
	case_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$tokenfirst %in% adposition[[language]])),])
	case_hraw_mlemma_entropy = entropy(c(case_hraw_mlemma_xmod,case_hraw_mlemma_modx), method="ML", unit="log2")
	#case_hpos_mlemma
	case_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$tokensecond %in% adposition[[language]])),])
	case_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$tokenfirst %in% adposition[[language]])),])
	case_hpos_mlemma_entropy = entropy(c(case_hpos_mlemma_xmod,case_hpos_mlemma_modx), method="ML", unit="log2")
	#case_hpos_mposlemma
	case_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "ADP") & (report$tokensecond %in% adposition[[language]])),])
	case_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "ADP") & (report$tokenfirst %in% adposition[[language]])),])
	case_hpos_mposlemma_entropy = entropy(c(case_hpos_mposlemma_xmod,case_hpos_mposlemma_modx), method="ML", unit="log2")
		}
	else {
	#case_hraw_mlemma
	case_hraw_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$lemmasecond %in% adposition[[language]])),])
	case_hraw_mlemma_modx = nrow(report[ which(report$order==modx & (report$lemmafirst %in% adposition[[language]])),])
	case_hraw_mlemma_entropy = entropy(c(case_hraw_mlemma_xmod,case_hraw_mlemma_modx), method="ML", unit="log2")
	#case_hpos_mlemma
	case_hpos_mlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$lemmasecond %in% adposition[[language]])),])
	case_hpos_mlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$lemmafirst %in% adposition[[language]])),])
	case_hpos_mlemma_entropy = entropy(c(case_hpos_mlemma_xmod,case_hpos_mlemma_modx), method="ML", unit="log2")
	#case_hpos_mposlemma
	case_hpos_mposlemma_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") &  (report$upossecond == "ADP") & (report$lemmasecond %in% adposition[[language]])),])
	case_hpos_mposlemma_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "ADP") & (report$lemmafirst %in% adposition[[language]])),])
	case_hpos_mposlemma_entropy = entropy(c(case_hpos_mposlemma_xmod,case_hpos_mposlemma_modx), method="ML", unit="log2")
	}
	}

	#Pos filters
	if (startsWith(dep,"acl")) {
	#h-raw_m-pos
	hraw_mpos_xmod = nrow(report[ which(report$order==xmod & (report$upossecond == "VERB" | report$upossecond == "ADJ" | report$upossecond == "NOUN" | report$upossecond == "PROPN")),])
	hraw_mpos_modx = nrow(report[ which(report$order==modx & (report$uposfirst == "VERB" | report$uposfirst == "ADJ" | report$uposfirst == "NOUN" | report$uposfirst == "PROPN")),])	
	hraw_mpos_entropy = entropy(c(hraw_mpos_xmod,hraw_mpos_modx), method="ML", unit="log2")
	#h-pos_m-raw	
	hpos_mraw_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN")),])
	hpos_mraw_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN")),])	
	hpos_mraw_entropy = entropy(c(hpos_mraw_xmod,hpos_mraw_modx), method="ML", unit="log2")
	#h-pos_m-pos
	hpos_mpos_xmod = nrow(report[ which(report$order==xmod & (report$uposfirst=="NOUN" | report$uposfirst=="PROPN") & (report$upossecond == "VERB" | report$upossecond == "ADJ" | report$upossecond == "NOUN" | report$upossecond == "PROPN" )),])
	hpos_mpos_modx = nrow(report[ which(report$order==modx & (report$upossecond=="NOUN" | report$upossecond=="PROPN") & (report$uposfirst == "VERB" | report$uposfirst == "ADJ" | report$uposfirst == "NOUN" | report$uposfirst == "PROPN")),])	
	hpos_mpos_entropy = entropy(c(hpos_mpos_xmod,hpos_mpos_modx), method="ML", unit="log2")
	}		
	
	
	row <- data.frame (language = language, source = source, no_sent = no_sent, dependency = dep, raw_modx = raw_modx, raw_xmod = raw_xmod, raw_frequency = raw_modx + raw_xmod, raw_entropy = raw_entropy, hraw_mpos_modx = hraw_mpos_modx, hraw_mpos_xmod = hraw_mpos_xmod, hraw_mpos_frequency = hraw_mpos_modx + hraw_mpos_xmod, hraw_mpos_entropy = hraw_mpos_entropy, hpos_mraw_modx = hpos_mraw_modx, hpos_mraw_xmod = hpos_mraw_xmod, hpos_mraw_frequency = hpos_mraw_modx + hpos_mraw_xmod, hpos_mraw_entropy = hpos_mraw_entropy, hpos_mpos_modx = hpos_mpos_modx, hpos_mpos_xmod = hpos_mpos_xmod, hpos_mpos_frequency = hpos_mpos_modx + hpos_mpos_xmod, hpos_mpos_entropy = hpos_mpos_entropy, art_hraw_mlemma_modx = art_hraw_mlemma_modx, art_hraw_mlemma_xmod = art_hraw_mlemma_xmod, art_hraw_mlemma_frequency = art_hraw_mlemma_modx + art_hraw_mlemma_xmod, art_hraw_mlemma_entropy = art_hraw_mlemma_entropy, art_hpos_mlemma_modx = art_hpos_mlemma_modx, art_hpos_mlemma_xmod = art_hpos_mlemma_xmod, art_hpos_mlemma_frequency = art_hpos_mlemma_modx + art_hpos_mlemma_xmod, art_hpos_mlemma_entropy = art_hpos_mlemma_entropy, art_hpos_mposlemma_modx = art_hpos_mposlemma_modx, art_hpos_mposlemma_xmod = art_hpos_mposlemma_xmod, art_hpos_mposlemma_frequency = art_hpos_mposlemma_modx + art_hpos_mposlemma_xmod, art_hpos_mposlemma_entropy = art_hpos_mposlemma_entropy, dem_hraw_mlemma_modx = dem_hraw_mlemma_modx, dem_hraw_mlemma_xmod = dem_hraw_mlemma_xmod, dem_hraw_mlemma_frequency = dem_hraw_mlemma_modx + dem_hraw_mlemma_xmod, dem_hraw_mlemma_entropy = dem_hraw_mlemma_entropy, dem_hpos_mlemma_modx = dem_hpos_mlemma_modx, dem_hpos_mlemma_xmod = dem_hpos_mlemma_xmod, dem_hpos_mlemma_frequency = dem_hpos_mlemma_modx + dem_hpos_mlemma_xmod, dem_hpos_mlemma_entropy = dem_hpos_mlemma_entropy, dem_hpos_mposlemma_modx = dem_hpos_mposlemma_modx, dem_hpos_mposlemma_xmod = dem_hpos_mposlemma_xmod, dem_hpos_mposlemma_frequency = dem_hpos_mposlemma_modx + dem_hpos_mposlemma_xmod, dem_hpos_mposlemma_entropy = dem_hpos_mposlemma_entropy, case_hraw_mlemma_modx = case_hraw_mlemma_modx, case_hraw_mlemma_xmod = case_hraw_mlemma_xmod, case_hraw_mlemma_frequency = case_hraw_mlemma_modx + case_hraw_mlemma_xmod, case_hraw_mlemma_entropy = case_hraw_mlemma_entropy, case_hpos_mlemma_modx = case_hpos_mlemma_modx, case_hpos_mlemma_xmod = case_hpos_mlemma_xmod, case_hpos_mlemma_frequency = case_hpos_mlemma_modx + case_hpos_mlemma_xmod, case_hpos_mlemma_entropy = case_hpos_mlemma_entropy, case_hpos_mposlemma_modx = case_hpos_mposlemma_modx, case_hpos_mposlemma_xmod = case_hpos_mposlemma_xmod, case_hpos_mposlemma_frequency = case_hpos_mposlemma_modx + case_hpos_mposlemma_xmod, case_hpos_mposlemma_entropy = case_hpos_mposlemma_entropy)
	df <- rbind(df, row)		}
		}
write.csv(x=df,file="../output-ciep-full.csv",row.names = FALSE)
