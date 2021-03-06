pbgpd_psilog <-
function 
(x, y,
mar1 = c(0, 1, 0.1), mar2 = c(0, 1, 0.1), dep=1.5,
asy  = 0, p = 3, 
asymin1=-2,
asymax1= 2,
asymin2= 0,
asymax2= 6, ...)
{
    A1    = expression((x^alpha + (1 - x)^alpha)^(1/alpha))
    fi1   = expression(c * t^a * (1 - t)^a + t)
 
    d1A1  = D(A1,"x")
    d2A1  = D(d1A1,"x")
    A     = function(x, alpha) eval({x<-x; alpha<-alpha; A1})
    d1A   = function(x, alpha) eval({x<-x; alpha<-alpha; d1A1})
    d2A   = function(x, alpha) eval({x<-x; alpha<-alpha; d2A1})
    d1fi1 = D(fi1,"t")
    d2fi1 = D(d1fi1,"t")
    fi    = function(t, c, a) eval({t<-t; c<-c; a<-a; fi1})
    d1fi  = function(t, c, a) eval({t<-t; c<-c; a<-a; d1fi1})
    d2fi  = function(t, c, a) eval({t<-t; c<-c; a<-a; d2fi1})

    Afi   = function(t, alpha, c, a) A(fi(t, c, a), alpha)
    d1Afi = function(t, alpha, c, a) d1A(fi(t, c, a), alpha) * d1fi(t, c, a)
    d2Afi = function(t, alpha, c, a) d2A(fi(t, c, a), alpha) * (d1fi(t, c, a))^2 + d1A(fi(t, c, a), alpha) * d2fi(t,c, a)
    mu    = function(x, y, alpha, c, a) (1/x + 1/y) * Afi(x/(x + y), alpha, c, a)

    param = as.numeric(c(mar1, mar2, dep, asy, p))
    mux   = param[1]; muy   = param[4]
    sigx  = param[2]; sigy  = param[5]
    gamx  = param[3]; gamy  = param[6]
    alpha = param[7]
    asy   = param[8]; p     = param[9]

    Hxy   = NULL
    error = FALSE
    xx    = seq(0, 1, 0.01)
    
    d2Axx                   = d2Afi(xx,alpha,asy,p)
    d2Axx[d2Axx==-Inf]       = NA
    if(min(d2Axx,na.rm=TRUE)<0 ) error=TRUE
    if(sigx<0 | sigy<0 | alpha>5 | alpha < 1.1 ) error=TRUE
    if(asy < asymin1 | asy > asymax1 | p < asymin2 | p > asymax2 ) error=TRUE #ezek lehetnenek bemeno parameterek is, a 0 koruli becslest segitik
    
    if (!error)
    {
    tx    = (1 + gamx * (x - mux)/sigx)^(1/gamx)
    ty    = (1 + gamy * (y - muy)/sigy)^(1/gamy)
    tx0   = (1 + gamx * (-mux)/sigx)^(1/gamx)
    ty0   = (1 + gamy * (-muy)/sigy)^(1/gamy)
    c0    = -mu(tx0, ty0, alpha, asy, p)
    Hxy   = 1/c0 * (mu(tx, ty, alpha, asy, p) - mu(pmin(tx,rep(tx0,length(tx))), pmin(ty,rep(ty0,length(tx))), alpha, asy, p))
    }
    else stop("invalid parameter(s)")
    Hxy
}
