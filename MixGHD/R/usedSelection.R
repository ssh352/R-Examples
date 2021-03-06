####For selection


cMSGHDSel <- function(data=NULL, gpar0=NULL, G=2, max.iter=100, label =NULL ,eps=1e-2, method="km" ,scale=TRUE,nr=NULL) {
  data=as.matrix(data)
  if( scale==TRUE)
  {data=scale(data)}
  pcol=ncol(data)
  # if (nrow(data)<((G-1)+G*(4*pcol+pcol*(pcol-1)/2)))stop('G is too big, number of parameters > n')
  if (is.null(data)) stop('data is null')
  if (nrow(data) == 1) stop('nrow(data) is equal to 1')
  #  if (ncol(data) == 1) stop('ncol(data) is equal to 1; This function currently only works with multivariate data p > 1')
  if (any(is.na(data))) stop('No NAs allowed.')
  if (is.null(G)) stop('G is NULL')
  #if ( G < 1) stop('G is not a positive integer')
  if (  max.iter< 1) stop('max.iter is not a positive integer')
  
  
  
  
  
  bico=-Inf
  t=length(G)
  BIC=matrix(NA,t,1)
  cont=0
  for(b in 1:t){
    mo=try(maincMSGHD(data=data, gpar0=gpar0, G=G[b], n=max.iter, eps=eps,  label=label, method=method,nr=nr),silent = TRUE)
    cont=cont+1
    if(is.list(mo)){
      bicn=mo$BIC
      BIC[cont]=bicn}
    else{bicn=-Inf
         BIC[cont]=NA}
    if(bicn>bico){
      bico=bicn
      sg=G[b]
      model=mo
    }
  }
  val=list(BIC=BIC,model=model)
   return(val)
}


MCGHDSel <- function(data=NULL, gpar0=NULL, G=2, max.iter=100, eps=1e-2,  label=NULL, method="km",scale=TRUE,nr=NULL ) {
  data=as.matrix(data)
  if( scale==TRUE){
    data=scale(data)}
  pcol=ncol(data)
  #if (nrow(data)<((G-1)+G*(4*pcol+2+pcol*(pcol-1)/2)))stop('G is too big, number of parameters > n')
  if (is.null(data)) stop('data is null')
  if (nrow(data) == 1) stop('nrow(data) is equal to 1')
  #if (ncol(data) == 1) stop('ncol(data) is equal to 1; This function currently only works with multivariate data p > 1')
  if (any(is.na(data))) stop('No NAs allowed.')
  if (is.null(G)) stop('G is NULL')
  #if ( G < 1) stop('G is not a positive integer')
  if (  max.iter< 1) stop('max.iter is not a positive integer')
  
  
  bico=-Inf
  t=length(G)
  BIC=matrix(NA,t,1)
  cont=0
  for(b in 1:t){
    mo=try(MainMCGHD(data=data, gpar0=gpar0, G=G[b], max.iter, eps,  label, method,nr=nr),silent = TRUE)
    cont=cont+1
    if(is.list(mo)){
      bicn=mo$BIC
      BIC[cont]=bicn}
    else{bicn=-Inf
         BIC[cont]=NA}
    if(bicn>bico){
      bico=bicn
      sg=G[b]
      model=mo
    }
  }
  val=list(BIC=BIC,model=model)
    return(val)
}



MGHDSel <- function(data=NULL, gpar0=NULL, G=2, max.iter=100, label =NULL , eps=1e-2, method="kmeans" ,scale=TRUE,nr=NULL ) {
  ##Expexctation Maximization estimation of GHD
  ##data
  ## G n clusters
  ##n number of iterations
  data=as.matrix(data)
  if( scale==TRUE){
    data=scale(as.matrix(data))}
  pcol=ncol(data)
  #if (nrow(data)<((G-1)+G*(2*pcol+2+pcol*(pcol-1)/2)))stop('G is too big, number of parameters > n')
  if (is.null(data)) stop('data is null')
  if (nrow(data) == 1) stop('nrow(data) is equal to 1')
  if (any(is.na(data))) stop('No NAs allowed.')
  if (is.null(G)) stop('G is NULL')
  #if ( G < 1) stop('G is not a positive integer')
  if ( max.iter < 1) stop('max.iter is not a positive integer')
  
  bico=-Inf
  t=length(G)
  BIC=matrix(NA,t,1)
  cont=0
  for(b in 1:t){
    mo=try(mainMGHD(data=data, gpar0=gpar0, G=G[b], n=max.iter, eps=eps,  label=label,method= method,nr=nr),silent = TRUE)
    cont=cont+1
    if(is.list(mo)){
      bicn=mo$BIC
      BIC[cont]=bicn}
    else{bicn=-Inf
         BIC[cont]=NA}
    if(bicn>bico){
      bico=bicn
      sg=G[b]
      model=mo
    }
  }
  val=list(BIC=BIC,model=model)
   return(val)
}



MGHFASel<- function(data=NULL, gpar0=NULL, G=2, max.iter=100, label =NULL  ,q=2,eps=1e-2, method="kmeans",scale=TRUE ,nr=NULL) {
  ##Expexctation Maximization estimation of GHD
  ##data
  ## G n clusters
  ##n number of iterations
  data=as.matrix(data)
  if( scale==TRUE)
  {data=scale(data)}
  pcol=ncol(data)
  #  if (nrow(data)<((G-1)+G*(3*pcol+2+pcol*q-q*(q-1)/2)))stop('G is too big, number of parameters > n')
  if (is.null(data)) stop('data is null')
  if (nrow(data) == 1) stop('nrow(data) is equal to 1')
  if (ncol(data) == 1) stop('ncol(data) is equal to 1; This function  only works with multivariate data p > 1')
  if (any(is.na(data))) stop('No NAs allowed.')
  if (is.null(G)) stop('G is NULL')
  #	if ( G < 1) stop('G is not a positive integer')
  if ( max.iter < 1) stop('max.iter is not a positive integer')
  #if ( q < 1) stop('n is not a positive integer')
  bico=-Inf
  t=length(G)
  tq=length(q)
  BIC=matrix(NA,t,tq)
  cont=0
  if(length(G)==1&length(q)==1){
    mo=(mainMGHFA(data=data, gpar0=gpar0, G=G,q=q, n=max.iter, eps=eps,  label=label,method= method))#,silent = TRUE
    val=list(BIC=mo$BIC,model=mo)
  }
  else{
    for(b2 in 1:tq){
      for(b in 1:t){
        ct=1
        while(ct<4 || is.list(mo)==FALSE){
          mo=try(mainMGHFA(data=data, gpar0=gpar0, G=G[b],q=q[b2], n=max.iter, eps=eps,  label=label,method= method,nr=nr),silent = TRUE)
          ct=ct+1}
        cont=cont+1
        if(is.list(mo)){
          bicn=mo$BIC
          BIC[b,b2]=bicn}
        else{bicn=-Inf
             BIC[b,b2]=NA}
        if(bicn>bico){
          bico=bicn
          sg=G[b]
          sq=q[b2]
          model=mo
        }
      }}
    val=list(BIC=BIC,model=model)
    
   
  return(val)
  
  
  }}





MSGHDSel <- function(data=NULL, gpar0=NULL, G=2, max.iter=100, label =NULL ,eps=1e-2, method="km",scale=TRUE,nr=NULL ) {
  data=as.matrix(data)
  if( scale==TRUE)
  {data=scale(data)}
  pcol=ncol(data)
  #  if (nrow(data)<((G-1)+G*(4*pcol+pcol*(pcol-1)/2)))stop('G is too big, number of parameters > n')
  if (is.null(data)) stop('data is null')
  if (nrow(data) == 1) stop('nrow(data) is equal to 1')
  # if (ncol(data) == 1) stop('ncol(data) is equal to 1; This function currently only works with multivariate data p > 1')
  if (any(is.na(data))) stop('No NAs allowed.')
  if (is.null(G)) stop('G is NULL')
  # if ( G < 1) stop('G is not a positive integer')
  if (  max.iter< 1) stop('max.iter is not a positive integer')
  
  
  
  bico=-Inf
  t=length(G)
  BIC=matrix(NA,t,1)
  cont=0
  for(b in 1:t){
    mo=try(mainMSGHD(data=data, gpar0=gpar0, G=G[b], n=max.iter, eps=eps,  label=label,method= method,nr=nr),silent = TRUE)
    cont=cont+1
    if(is.list(mo)){
      bicn=mo$BIC
      BIC[cont]=bicn}
    else{bicn=-Inf
         BIC[cont]=NA}
    if(bicn>bico){
      bico=bicn
      sg=G[b]
      model=mo
    }
  }
  val=list(BIC=BIC,model=model)
   return(val)
}

