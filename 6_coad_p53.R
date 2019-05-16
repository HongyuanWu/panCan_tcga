
suppressMessages(library(RnBeads))
options(bitmapType="cairo")
options(scipen=999)

rnb.set.norm=load.rnb.set("/root/TCGA/Rnbeads/COAD/RnBeads_normalization/rnb.set.norm_withNormal.RData.zip")


TUMOR = read.csv("/root/TCGA/Rnbeads/COAD/COAD_TP53_mutation_info_withNormal.csv",header=TRUE)
TUMOR = as.character(TUMOR$Variant_Classification)
TUMOR[TUMOR!="NORMAL" & TUMOR!="WT"] = "MUT"
rnb.set.norm@pheno = data.frame(rnb.set.norm@pheno, Tumor = TUMOR)

rnb.set.norm_noNormal=remove.samples(rnb.set.norm,samples(rnb.set.norm)[which(rnb.set.norm@pheno$Tumor=="NORMAL")])

num.cores <- 20
parallel.setup(num.cores)
dmc <- rnb.execute.computeDiffMeth(rnb.set.norm_noNormal,pheno.cols=c("Tumor"))
comparison <- get.comparisons(dmc)[1]
dmc_table <-get.table(dmc, comparison, "sites", return.data.frame=TRUE)

table(abs(dmc_table$mean.diff)>.25 & dmc_table$diffmeth.p.adj.fdr<0.05)