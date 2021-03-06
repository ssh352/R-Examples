getChangepoints = function(readMatrix, verbose=TRUE, pOri=c(0.49,0.51), error=1e-5, maxIter=1000){
  cat("Number of loci:", dim(readMatrix)[1], "\n")
  AN = readMatrix$AN
  BN = readMatrix$BN
  AT = readMatrix$AT
  BT = readMatrix$BT
  L = 1000
  d = 200
  N = length(AT)
  n = floor(N/L)
  tauhat = c()
  for (i in 1:(n+1)){
    id1 = min(L*(i-1)+1, N)
    id2 = min(L*i+d, N)
    if (id2-id1 > d){
      ids = id1:id2
      if (verbose){
        cat("Scanning region between variants", id1, "to", id2, "for change-points ... \n")
      }
      mytau = ScanCBS2dEM(AT[ids], BT[ids], AN[ids], BN[ids], error=error, maxIter=maxIter, pOri=pOri)
      if (length(mytau)>2){
        tauhat = c(tauhat, mytau[2:(length(mytau)-1)]+id1-1)
        if (verbose){
          cat("  Candidate change-point(s):", mytau[2:(length(mytau)-1)]+id1-1, "\n")
          cat("  Adding", mytau[2:(length(mytau)-1)]+id1-1, "to current change-point list.\n")
          cat("  Current change-point list:", tauhat, "\n")
        }
      }else{
        if (verbose){
          cat(" No change-point found in this region.\n")
        }
      }
    }
  }
  cat("\n")
  if (length(tauhat)>0){
    tauhat = sort(unique(tauhat))
    cat("Estimated change-points of the whole sequence:", tauhat, "\n")
  }else{
    cat("No change-point found in this sequence.")
  }
  return(tauhat)
}

getASCN = function(readMatrix, rdep=NULL, tauhat=NULL, threshold=0.15, pOri=c(0.49,0.51), error=1e-5, maxIter=1000){
  AN = readMatrix$AN
  BN = readMatrix$BN
  AT = readMatrix$AT
  BT = readMatrix$BT
  if (is.null(rdep)) rdep = median(AT+BT)/median(AN+BN)
  if (is.null(tauhat)) tauhat = getChangepoints(readMatrix, pOri=pOri, error=error, maxIter=maxIter)
  N = length(AT)
  tau = sort(unique(c(1,tauhat,N)))
  K = length(tau)-1
  pa = pb = rep(0,K)
  for (i in 1:K){
    ids = tau[i]:(tau[i+1]-1)
    if (i==K) ids = tau[i]:tau[i+1]
    p = as.numeric(.Call("GetP", as.numeric(AT[ids]), as.numeric(BT[ids]), as.numeric(AN[ids]), as.numeric(BN[ids]), as.numeric(error), as.numeric(maxIter), as.numeric(pOri), PACKAGE="falcon"))
    pa[i] = p[1]
    pb[i] = p[2]
    ## determine whether two groups or one group
    if (diff(p)<0.1){
      temp = as.numeric(.Call("LikH", as.numeric(AT[ids]), as.numeric(BT[ids]), as.numeric(AN[ids]), as.numeric(BN[ids]), as.numeric(p), PACKAGE="falcon"))
      p2 = sum(AT[ids]+BT[ids])/sum(AT[ids]+BT[ids]+AN[ids]+BN[ids])
      temp2 = as.numeric(.Call("Lik", as.numeric(AT[ids]), as.numeric(BT[ids]), as.numeric(AN[ids]), as.numeric(BN[ids]), as.numeric(rep(p2,2)), PACKAGE="falcon"))
      if (!is.na(temp)[1] && !is.na(temp[2]) && !is.na(temp2)){
        bic = temp[1] - temp2 - temp[2]/2 + log(p2*(1-p2)*sum(AT[ids]+BT[ids]+AN[ids]+BN[ids]))/2 + log(2*pi)/2
      } else if (!is.na(temp)[1] && !is.na(temp2)){
        bic = temp[1] - temp2 + log(p2*(1-p2)*sum(AT[ids]+BT[ids]+AN[ids]+BN[ids]))/2 + log(2*pi)/2
      }
      if (bic<0){
        pa[i] = p2
        pb[i] = p2
      }
    }
  }
  rawcns1 = pa/(1-pa)/rdep
  rawcns2 = pb/(1-pb)/rdep
  cns1 = hardthres(rawcns1, low=1-threshold, high=1+threshold)
  cns2 = hardthres(rawcns2, low=1-threshold, high=1+threshold)
  Haplotype = list()
  for (i in 1:K){
    if (cns1[i]!=cns2[i]){
      ids = tau[i]:(tau[i+1]-1)
      if (i==K) ids = tau[i]:tau[i+1]
      gt = 1/(1+(pb[i]/pa[i])^(AT[ids]-BT[ids])*((1-pb[i])/(1-pa[i]))^(AN[ids]-BN[ids]))
      temp3 = rep("A",length(ids))
      temp3[which(gt>0.5)] = "B"
      Haplotype[[i]] = temp3
    }
  }
  return(list(tauhat=tauhat, ascn=rbind(cns1,cns2), Haplotype=Haplotype, readMatrix=readMatrix))
}


view = function(output, pos=NULL, rdep=NULL, plot="all", ...){
  readMatrix = output$readMatrix
  tauhat = output$tauhat
  ascn = output$ascn
  AN = readMatrix$AN
  BN = readMatrix$BN
  AT = readMatrix$AT
  BT = readMatrix$BT
  
  N = length(AT)
  tau = sort(unique(c(1,tauhat,N)))
  ascn1 = ascn[1,]
  ascn2 = ascn[2,]
  if (is.null(pos)){
    pos = 1:N
    myxlab = "SNP #"
  }else{
    myxlab = "Position (bp)"
  }
  if (is.null(rdep)) rdep = median(AT+BT)/median(AN+BN)
  
  if (plot=="all"){
    par(mfrow=c(3,1))
  }
  if (plot=="all" || plot=="Afreq"){
    plot(pos, AN/(AN+BN), xlab=myxlab, ylim=c(0,1),ylab="A freq", col="gray", pch=".",...)
    points(pos, AT/(AT+BT), pch=".",...)
    abline(h=0.5, col="green")
    abline(v=pos[tau], col="purple", lty=2)
  }
  if (plot=="all" || plot=="RelativeCoverage"){
    plot(pos, (AT+BT)/(AN+BN)/rdep, ylab="Relative Coverage", xlab=myxlab, pch=".",...)
    abline(h=1,col="green")
    abline(v=pos[tau], col="purple", lty=2)
  }
  if (plot=="all" || plot=="ASCN"){
    plotCN(N, tau, ascn, pos=pos,xlab=myxlab, ...)
  }
}



  
