parSegment <-
function(CNAobj,ranseed=NULL,distrib=c("vanilla","Rparallel"),
	njobs=1,out=c("full","skinny"),...){
	if(data.class(CNAobj)!="CNA")stop("The 1st argument must be of class CNA.")
	dtype<-attr(CNAobj,"data.type")
	chrom<-CNAobj$chrom
	maploc<-CNAobj$maploc
	class(CNAobj)<-"list"
	distrib<-match.arg(distrib)
	out<-match.arg(out)
	if(distrib=="Rparallel"){
		ncores<-min(njobs,length(CNAobj),detectCores())
		cl<-parallel::makeCluster(getOption("cl.cores",ncores))
		parallel::clusterEvalQ(cl=cl,expr=requireNamespace("DNAcopy"))
	}
	processed<-switch(distrib,
		vanilla=lapply(X=CNAobj,FUN=segmentWrapper,chrom=chrom,maploc=maploc,
			dtype=dtype,ranseed=ranseed,...),
		Rparallel=parLapply(cl,X=CNAobj,fun=segmentWrapper,chrom=chrom,
			maploc=maploc,dtype=dtype,ranseed=ranseed,...))
	if(distrib=="Rparallel")stopCluster(cl)
	joinproc<-do.call("rbind",processed)
	joinproc[,"ID"]<-rep(names(CNAobj)[-(1:2)],
		times=unlist(lapply(processed,nrow)))
	row.names(joinproc)<-NULL
	returnme<-vector(mode="list",length=4)
	class(returnme)<-"DNAcopy"
	names(returnme)<-c("data","output","segRows","call")
	returnme$output<-joinproc[,1:6,drop=F]
	returnme$segRows<-joinproc[,7:ncol(joinproc),drop=F]
	returnme$call<-match.call()
	if(out=="full"){
		class(CNAobj)<-c("CNA","data.frame")
		returnme$data<-CNAobj
	}
	return(returnme)
}
