infile <- commandArgs()[4] 
# outfile <- commandArgs()[5] # changed 2018-03-06 (blacked out)
options(scipen=99)
#cat("Merging across names for ",infile,"\n")
df <- read.table(as.is=TRUE,infile)
#cat("  regions in input ",dim(df)[1],"\n")
#df <- df[order(df$V1,df$V4,df$V2),]
df <- df[order(df$V4,df$V1,df$V2),] # changed 2018-03-06
df$V2 <- df$V2+1 # get up from bed
suppressMessages(suppressWarnings(require(IRanges,quietly = TRUE,warn.conflicts = FALSE)))
svar <- rep(0,dim(df)[1])
evar <- rep(0,dim(df)[1])
tester=""
for(i in 1:dim(df)[1]){
#	if(i %% 100000 == 0)print(i)
			if(df$V4[i]!=tester){svar[i]<-i;tester <- df$V4[i];evar[i]<-i-1}
}
svar <- svar[svar>0]
evar <- evar[evar>0]
evar <- c(evar,dim(df)[1])
#cat("  names in input ",length(evar),"\n")
suppressMessages(suppressWarnings(require(parallel,quietly = TRUE,warn.conflicts = FALSE)))
var1 <- mclapply(seq_along(svar),function(x)df[svar[x]:evar[x],],mc.cores = detectCores()) # 17 sec
var2 <- mclapply(var1,function(x)IRanges(start=x$V2,end=x$V3),mc.cores = detectCores()) #4 s with 10 core
var3 <- mclapply(var2,reduce,mc.cores = detectCores()) # 12 s with 10 cores

nregs <- unlist(lapply(var3,function(x)length(start(x))))
namesout <- rep(unique(df$V4),nregs)
#cat("  regions in output ",length(namesout),"\n")
dfout <- as.data.frame(df$V1[match(namesout,df$V4)])
colnames(dfout) <- "chr"
dfout$starts <- unlist(lapply(var3,function(x)start(x)))
dfout$ends <- unlist(lapply(var3,function(x)end(x)))
dfout$name <- namesout
dfout$val <- df$V5[match(namesout,df$V4)]
dfout$strand <- df$V6[match(namesout,df$V4)]
dfout$starts <- dfout$starts-1 # back to bed
write.table(sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE,x=dfout)
#write.table(sep=" ", col.names=FALSE, row.names=FALSE, quote=FALSE,x=dfout,file="tempmogfile")
#write.table(sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE,x=dfout,file="tempmogfile") # changed 2018-03-06 (blacked out)
#system(paste0("cat tempmogfile | sort -k1,1 -k4,4 -k2,2n > ",outfile))# changed 2018-03-06 (blacked out)
#	system("rm tempmogfile")# changed 2018-03-06 (blacked out)
#cat("Finished... output in ",outfile,"\n")# changed 2018-03-06 (blacked out)
