### Converted from MATLAB by Tim J. Benham, 2014

## function [X, rho, nar, ngibbs] = rmvnrnd(mu,sigma,N,A,b,rhoThr)
## %RMVNRND Draw from the  truncated multivariate normal distribution.
## %   X = rmvnrnd(MU,SIG,N,A,B) returns in N-by-P matrix X a
## %   random sample drawn from the P-dimensional multivariate normal
## %   distribution with mean MU and covariance SIG truncated to a
## %   region bounded by the hyperplanes defined by the inequalities Ax<=B.
## %
## %   [X,RHO,NAR,NGIBBS]  = rmvnrnd(MU,SIG,N,A,B) returns the
## %   acceptance rate RHO of the accept-reject portion of the algorithm
## %   (see below), the number NAR of returned samples generated by
## %   the accept-reject algorithm, and the number NGIBBS returned by
## %   the Gibbs sampler portion of the algorithm.
## %
## %   rmvnrnd(MU,SIG,N,A,B,RHOTHR) sets the minimum acceptable
## %   acceptance rate for the accept-reject portion of the algorithm
## %   to RHOTHR. The default is the empirically identified value
## %   2.9e-4.
## %
## %   ALGORITHM
## %   The function begins by drawing samples from the untruncated MVN
## %   distribution and rejecting those which fail to satisfy the
## %   constraints. If, after a number of iterations with escalating
## %   sample sizes, the acceptance rate is less than RHOTHR it
## %   switches to a Gibbs sampler.
## %
## % ACKNOWLEDGEMENT
## %   This makes use of TruncatedGaussian by Bruno Luong (File ID:
## %   #23832) to generate draws from the one dimensional truncated normal.
## %
## %   REFERENCES
## %   Robert, C.P, "Simulation of truncated normal variables",
## %   Statistics and Computing, pp. 121-125 (1995).

## % Copyright 2011 Tim J. Benham, School of Mathematics and Physics,
## %                University of Queensland.

rtmvnorm <- function(N, mu, sigma, A, b,..., rhoThr=NULL, maxSample=NULL) {

    ## Constant parameters
    defaultRhoThr = 1e-4 # min. acceptance rate to apply accept-reject sampling.
    defaultMaxSample <- 1e6  # largest sample to draw

    ##
    ## Process input arguments.
    ##
    if (is.null(rhoThr) || rhoThr<0) rhoThr = defaultRhoThr
    if (is.null(maxSample) || maxSample<0) maxSample = defaultMaxSample
    mu <- t(mu)
    p <- length(mu)                     #dimensions
    if (p<1) stop('Problem dimension must be at least 1')
    if (is.null(A) || is.na(A) || !is.matrix(A) || dim(A)[2]==0) {
        A <- matrix(rep(0,p),nrow=1)
        b=c(0);
    }
    A <- t(A); b <- t(b);
    m <- dim(A)[2]                      #no. constraints
    if (length(b) != m) stop('A and b not conformable')

    ##
    ## initialize return arguments
    ##
    X <- matrix(nrow=N, ncol=p)
    nar <- 0; ngibbs <- 0; rho <- 1

###
### Approach 1 : Accept/Reject
###
    if (rhoThr<1) {
        ## Try accept-reject approach.
        n <- 0 # no. accepted
        trials <- 0; passes <- 0;
        s <- N
        while (n<N && (rho>rhoThr || s<maxSample)) {
#            cat('n:',n,a'rho:',rho,'s:',s,'\n')
            R <- mvrnorm(s,mu,sigma)
            YY <- R %*% A <= matrix(rep(b,s),nrow=s,byrow=T)
            YY <- matrix(as.numeric(YY),nrow=s)
            R <- R[rowSums(YY) == m, ,drop=F]
            nr <- dim(R)[1]             #no. valid proposals
            if (nr > 0) {
                X[(n+1):min(N,n+nr),] <- R[1:min(N-n,nr),]
                nar <- nar + min(N,n+nr) - n
            }
            n <- n+nr; trials <- trials+s;
            rho <- n/trials;
            if (rho>0) {
                s <- min(maxSample, ceiling((N-n)/rho), 10*s)
            } else {
                s = min(maxSample,10*s)
            }
            passes <- passes+1
        }
    }

###
### Approach 2: Gibbs sampler of Robert, 1995.
###
    if (nar < N) {
        ##     % choose starting point
        if (nar>0)
            x <- X[nar,]
        else
            x <- mu;

        ##     set up inverse Sigma
        SigmaInv <- ginv(sigma)
        n <- nar

        while (n<N) {
            ## choose p new components
            for (i in 1:p) {
                ## Sigmai_i is the (p-1) vector derived from the i-th
                ## column of Sigma by removing the i-th row term.
               Sigmai_i = sigma[-i,i];

               ## Sigma_i_iInv is the inverse of the (p-1)x(p-1)
               ## matrix derived from Sigma = (sigma(ij) ) by
               ## eliminating its i-th row and its i-th column

               Sigma_i_iInv = SigmaInv[-i,-i,drop=F] -
                 SigmaInv[-i,i,drop=F] %*% t(SigmaInv[-i,i,drop=F]) /
                         SigmaInv[i,i,drop=F];


               ## x_i is the (p-1) vector of components not being updated
               ## at this iteration. /// mu_i
               x_i = x[-i,drop=F];
               mu_i = mu[-i,drop=F];
               ## mui is E(xi|x_i)
               mui = mu[i] + t(Sigmai_i) %*% Sigma_i_iInv %*%
                   as.matrix(x_i - mu_i, ncol=1);
               s2i = sigma[i,i] - t(Sigmai_i)%*%Sigma_i_iInv%*%Sigmai_i;

               ## Find points where the line with the (p-1) components x_i
               ## fixed intersects the bounding polytope.
               ## A_i is the (p-1) x m matrix derived from A by removing
               ## the i-th row.
               A_i = A[-i,,drop=F];
               ## Ai is the i-th row of A
               Ai = A[i,,drop=F]
               c = (b-x_i %*% A_i)/Ai
               lb = max(c[Ai<0])
               if (is.null(lb) || is.na(lb) || length(lb)==0) lb=-Inf
               ub = min(c[Ai>0])
               if (length(ub)==0) ub=Inf

##             % now draw from the 1-d normal truncated to [lb, ub]
               x[i] <- rtnorm(1,mean=mui,sd=sqrt(s2i),lower=lb,upper=ub)
           }
            n = n + 1;
            X[n,] = x;
            ngibbs = ngibbs+1;
        }
    }

    return (list(X=X,rho=rho,nar=nar,ngibbs=ngibbs))
}
