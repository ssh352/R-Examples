url.exists = function(x, ...) {
    if(requireNamespace2("RCurl"))
        RCurl::url.exists(x, ...)
    else {
        con = url(x)
        on.exit(close(con))
        res = tryCatch(readLines(con), error = function(e) e)
        if(is(res, "error"))
            FALSE
        else
            TRUE
    }
}
##' make file url
##'
##' @param path The path to wrap in a file:// URL
##' @return A valid file URL
##' @export
makeFileURL = function(path) {
  if(Sys.info()["sysname"] == "Windows") {
      .winFileURL(path)
  } else
    paste0("file://", normalizePath2(path))
}

isWindows = function( ) tolower(Sys.info()["sysname"]) == "windows"

##' Get path from file URL
##'
##' @param fileurl A file url (beginning in file://)
##' @return The system directory path that \code{fileurl} points to
##' @export
fileFromFileURL = function(fileurl) {
    if(!isWindows())
        ret = gsub("file://",  "" , fileurl, fixed=TRUE)
    else
        ret = .winFileFromURL(fileurl)

}

.winFileFromURL = function(fileurl) {
    if(grepl("file:///", fileurl))
        ret = gsub("^file:///", "", fileurl)
    else if (grepl("^file://[[:alpha:]]", fileurl))
        ret = gsub("^file:",  "", fileurl)
    ret = gsub("%20", " ", ret)
    normalizePath2(ret)
}

.winFileURL = function(path) {
    path = normalizePath2(path, winslash="/")
    path = gsub(" ", "%20", path)
    if(grepl("^//", path))
        paste0("file:", path)
    else
        paste0("file:///", path)
}

remOtherPkgVersions = function(pkgname, version, repodir, storagedir, verbose=FALSE) {
    if(is.na(version))
        return()
    tballpat = paste0(pkgname, "_")
  
  allinrepo = list.files(repodir, pattern = tballpat, full.names=TRUE)
  wrongvers = !grepl(version, allinrepo, fixed=TRUE)
  if(all(!wrongvers))
    return()
  if(verbose)
    message(sprintf("found %d other versions of the package in the repo directory (%s). Moving them to the storage directory (%s)",
                    sum(wrongvers), repodir, storagedir))
  file.rename(allinrepo[wrongvers], 
              file.path(storagedir, basename(allinrepo[wrongvers])))
}

fileFromBuiltPkg = function(archive, files, ...) {
  filname = basename(archive)
  ext = gsub(".*_[^[:alpha:]]*(\\..*)$", "\\1", filname)
  fun = switch(ext,
         ".zip" = unzip,
         ".tar.gz"= untar,
         "tgz" = untar,
         stop(sprintf("unrecognized extension %s", ext))
  )
  
  fun(archive, files = files, ...)
}


##' R executable
##' @param cmd the R CMD to run. "build", "check", "INSTALL", or "" (for none)
##' @param options The options to pass to the command
##' @export
Rcmd = function(cmd = c("build", "check", "INSTALL", ""), options) {
  cmd = match.arg(arg=cmd)
  cmdpart = if(nchar(cmd)) paste("CMD", cmd) else ""
	paste(file.path(R.home("bin"), "R"), cmdpart,  options)
}

##'Check if a directory contains package sources
##' @param dir The directory
##' @export
checkIsPkgDir = function (dir)
{
    fils = list.files(dir)
    any(grepl("^DESCRIPTION$", fils))
}

##'Find a package directory within an SCM checkout
##' @param rootdir The directory of the checkout
##' @param branch The branch to navigate to
##' @param subdir The subdirectory to navigate to
##' @param param a SwitchrParam object
##' @return A path to the Package sources
##' @export
findPkgDir = function(rootdir, branch, subdir,param)
{

    if(!length(subdir))
        subdir = "."
    ret = NULL
    name = basename(rootdir)
    #does it have the trunk, branches, tags layout?
    if(checkStdSVN(rootdir))
    {
        if(is.null(branch) || branch %in% c("master", "trunk"))
        {
            ret = file.path(rootdir, "trunk")
        } else {
            ret = file.path(rootdir, "branches", branch)
        }
    } else if(file.exists(file.path(rootdir, ".git"))) {
        if(is.null(branch) || branch == "trunk")
            branch = "master"
        gitChangeBranch(rootdir, branch, param = param)
        ret = rootdir
    } else if ( is.null(branch) || branch %in% c("master", "trunk")) {
        ret = rootdir
    } else {
        warning(paste0("The svn repository at ", rootdir,
                       " does not appear to have branches. ",
                       "Unable to process this source."))
        logfun(param)(name, paste("The SCM repository does not appear to have",
                                  "branches and a non-trunk/non-master branch",
                                  "was selected"),  type="both")
        return(NULL)
    }

    ret = file.path(ret, subdir)
    ##we somehow got a return file that doesn't exist on the file system.
    ##This is a problem with GRAN logic, not with packages/user activity
    if(!file.exists(ret))
    {
        logfun(param)(name, paste("Unable to find subdirectory", subdir,
                                 "in branch", branch), type="both")
        warning(paste0("Constructed temporary package directory",ret,
                       " doesn't appear to  exist after svn checkout. ",
                       "Missing branch?"))
        return(NULL)
    }
    
    ##Find a package. First look in ret, then in ret/package and ret/pkg
    ##we could be more general and allow people to specify subdirectories...
    if(!checkIsPkgDir(ret))
    {
        logfun(param)(name, paste("Specified branch/subdirectory combination",
                                 "does not appear to contain an R package"),
                                  type="both")
        ret = NULL
    }
    ret
}



makeUserFun = function(scm_auth, url)
    {
        ind = sapply(names(scm_auth), function(pat) grepl(pat, url, fixed=TRUE))
        if(any(ind))
            scm_auth[[which(ind)]][1]
        else
            ""

    }

makePwdFun = function(scm_auth, url)
    {
        ind = sapply(names(scm_auth), function(pat) grepl(pat, url, fixed=TRUE))
        if(any(ind))
            scm_auth[[which(ind)]][2]
        else
            ""
       
    }

##' Create a PkgSource object for a package
##' @param url The url of the package sources
##' @param type The source type.
##' @param user A function which, when called, returns the username to use when
##' when checking the soources out
##' @param password A function which returns the password to use when checking
##' out the sources
##' @param scm_auth A list of username-password pairs, named with regular
##' expressions to match against url when constructing the
##' defaults for \code{user} and \code{password}
##' @param prefer_svn Currently unused.
##' @param \dots Passed directly to constructors for PkgSource superclasses
##' @export
makeSource = function(url, type, user, password, scm_auth, prefer_svn = FALSE, ...) {
    if(is.na(type))
        type = "unknown"
    type = tolower(type)
    if(missing(user))
        user = makeUserFun(scm_auth = scm_auth, url = url)
    if(missing(password))
        password = makePwdFun(scm_auth= scm_auth, url = url)
    if(type == "git" && grepl("github", url))
        type = "github"

    ret = switch(type,
           svn  = new("SVNSource", location = url, user = user,
               password = password, ...),
           local = new("LocalSource", location = url, user = user,
               password= password, ...),
           git = new("GitSource", location = url, user = user,
               password = password,  ...),
           github = new("GithubSource", location = url, user = user,
               password = password, ...),
        cran = new("CRANSource", location = url, user = "", password = "", ...),
        bioc = new("BiocSource", location = url, user = "readonly", password = "readonly", ...),
        tarball = new("TarballSource", location = url, user = "", password ="", ...),
           stop("unsupported source type")
           )
    if( (type=="git" || type == "github") && is.na(ret@branch))
        ret@branch = "master"
    else if (type=="svn" && (!length(ret@branch) || is.na(ret@branch)))
        ret@branch = "trunk"
    if(is(ret, "GitSource") && prefer_svn) {
        ret2 = tryCatch(as(ret, "SVNSource"), error = function(x) x)
        if(!is(ret2, "error"))
            ret = ret2
    }
    ret
}

##' Construct pockage directory path
##' @param basepath The parent directory for the package directory
##' @param name The name of the package
##' @param subdir The subdirectory within a package source that
##' the actual package root directory will reside in.
##' @param scm_type Tye type of scm the package sources will be
##' checked out from
##' @param branch The branch from which the package will be retrieved.
##' @return A path
##' @note Unlike \code{\link{findPkgDir}} this does not look for existing
##' package source directories. It only constructs the path.
##' 
##' @export
getPkgDir = function(basepath,name,  subdir, scm_type, branch)
{

    
    basepath = normalizePath2(basepath)
    if(!file.exists(file.path(basepath, name)))
        stop("directory not found")
    ##svn
##    if(file.exists(file.path(basepath, name, ".svn")))
    if(scm_type == "svn")
    {
        if(checkStdSVN(file.path(basepath, name)))
        {
            if(is.na(branch) || branch == "trunk" || branch == "master")
                brdir = "trunk"
            else
                brdir = file.path("branches", branch)

        } else {
            brdir = "."

        }
    } else ## git or local, neither have explicit dirs for branching
        brdir = "."

    normalizePath2(file.path(basepath,name, brdir, subdir))
}


##' normalizePath2
##'
##' Attempt to normalize a relative path to an absolute one. Optionally without
##' resolving symlinks on non-Windows systems
##' @param path The path to normalize
##' @param follow.symlinks Should symlinks (other than . and ..)
##' be resolved to their physical locations? (FALSE)
##' @param winslash The value of winslash to be passed down to normalizePath
##' on windows systems
##' @param mustWork logical. Passed to normalizePath on windows. Ignored otherwise.
##' @return The normalized path.
##' @export
normalizePath2 = function(path, follow.symlinks=FALSE, winslash = "\\", mustWork = NA)
    {
        
        if(follow.symlinks || Sys.info()["sysname"]=="Windows")
            return(normalizePath(path, winslash = winslash, mustWork = mustWork))
        else {
            if(substr(path, 1, 1) == "~")
                path = path.expand(path)
            ##paths starting with / for example
            else if(substr(path, 1, 1) == .Platform$file.sep)

                path  = path
            else if (substr(path, 1, 2) == "..") {
                tmppath = getwd()
                while(substr(path, 1, 2) == "..") {
                    tmppath = dirname(tmppath)
                    path = substr(path, 3, nchar(path))
                    if(substr(path, 1, 1) == .Platform$file.sep)
                        path = substr(path, 2, nchar(path))
                }
                path = file.path(tmppath, path)
            } else if(grepl("^\\.*[[:alnum:]]", path))
                path = file.path(getwd(), path)
            else if (substr(path, 1,1) == ".")
                path = file.path(getwd(), substr(path,2, nchar(path)))
            path = gsub(paste(rep(.Platform$file.sep, 2), collapse=""), .Platform$file.sep, path, fixed=TRUE)
            path
            
        }
    }





##source an initialization script (e.g. .bashrc) if specified
## in sh_init_script(repo)
##' system_w_init
##'
##' Run a system command with an optional intialization script (e.g. a .bashrc
##' sourced first).
##' @param cmd The text of the command. Must be length 1.
##' @param dir The directory that the command should be executed in. The working directory will be temporarily changed to this dir,
##' but will be changed back upon exit of system_w_init.
##' @param init (optional) a character value indicating the
##' location of an initialization shell script.
##' @param \dots additional parameters passed directly to \code{\link{system}}.
##' @param param A SwitchrParam object. The shell initialization
##' script associated with this object is used when \code{init} is
##' not specified (length 0).
##' @return Depends, see \code{\link{system}} for details.
##' @export
system_w_init = function(cmd, dir,
    init = character(), ..., param = SwitchrParam())
{
    pause = shell_timing(param) > 0

    if(!(pause||isWindows()) && length(cmd) > 1)
        cmd = paste(cmd, collapse=" ; ")
    
    if(!length(init) && !is.null(param))
        init = sh_init_script(param)
    if(length(init) && nchar(init)) 
        cmd = paste(paste("source", init, ";"), cmd)
    
    if(!missing(dir)) {
      oldwd  = getwd()
      setwd(dir)
      on.exit(setwd(oldwd))
    }
    if(length(cmd) > 1) {
        res = sapply(cmd, function(x, ...) {
                         res = system(x, ...)
                         Sys.sleep(shell_timing(param))
                         res
                     }, ...)
        
        tail(res, 1)
    } else {
        system(cmd, ...)
    }
}

highestVs = c(9, 14, 2)


decrBiocVersion = function(biocVers) {
    vals = strsplit(biocVers, ".", fixed=TRUE)[[1]]
    vals  = as.numeric(vals)
    if(identical(vals, c(1,0))) {
        NULL
    } else if (vals[2] == 0) {
        vals[1] = vals[1] - 1 #decrement major version
        vals[2] = highestVs[ vals[1] ] #set to highest minor version for that major
    } else {
        vals[2] = vals[2] - 1
    }
    paste(vals, collapse=".")
}

decrBiocRepo = function(repos, vers = biocVersFromRepo(repos)) {
    if(!is.character(vers))
        vers = as.character(vers)

    pieces = strsplit(repos, vers, fixed=TRUE)
    newvers = decrBiocVersion(vers)
    if(is.null(newvers)) {
        warning("Cannot decrement bioc repo version below 1.0")
        return(NULL)
    }
    sapply(pieces, function(x) paste0(x, collapse = newvers))
}

biocVersFromRepo = function(repos) gsub(".*/([0-9][^/]*)/.*", "\\1", repos[1])

biocReposFromVers = function(vers = develVers) {
    if(!requireNamespace2("BiocInstaller"))
        stop("Unable to manipulate bioc versions without BiocInstaller installed")
   
    repos = head(BiocInstaller::biocinstallRepos(), -1)
    bef= gsub("(.*/)[0-9][^/]*/.*", "\\1", repos)
    af = gsub(".*/[0-9][^/]*(/.*)", "\\1", repos)
    paste0(bef, vers, af)
}    

highestBiocVers = function(repos){
    if(!requireNamespace2("BiocInstaller"))
        stop("Unable to determine bioc versions without BiocInstaller installed")
    else if(missing(repos))
        ## head -1 removes the last element
        repos =head(BiocInstaller::biocinstallRepos(), -1)
    majvers = length(highestVs)
    vers = paste(majvers, highestVs[majvers], sep=".")
    biocReposFromVers(vers = vers)
}




#system(..., intern=TRUE) throws an error if the the command fails,
#and has attr(out, "status") > 0 if the called program returns non-zero status.
##' Identify error states from R or external programs
##' @param out An R object representing output
##' @return TRUE if out is an error object, or has an attribute called "status" which is > 0
##' @export
errorOrNonZero = function(out)
{
    if(is(out, "error") ||
       (!is.null(attr(out, "status")) && attr(out, "status") > 0))
        TRUE
    else
        FALSE
}


## NB this will give different behavior in R versions that
## provide requireNamespace and thsoe that don't re the search path.
## Not ideal, but otherwise switchr will fail to install at all.
requireNamespace2 = function(...) {
    if(exists("requireNamespace"))
        requireNamespace(...)
    else
        require(...)
}

## this will give identical behavior but will be less efficient
## when paste0 doesn't exist.
if(!exists("paste0"))
    paste0 = function(...) paste(..., sep="")
        

sourceFromManifest = function(pkg, manifest, scm_auths = list(bioconductor=c("readonly", "readonly")), ...) {
    mandf = manifest_df(manifest)
    manrow = mandf[mandf$name == pkg, ]
    ##https://github.com/gmbecker/ProteinVis/archive/IndelsOverlay.zip
    ## for IndelsOverlay branch
    src = makeSource(name = pkg,
        type = manrow$type,
        url = manrow$url, branch = manrow$branch,
        subdir = manrow$subdir,
        scm_auth = scm_auths,...)
    src
}

isWindows = function() {
  Sys.info()["sysname"] == "Windows"
}

haveGit = function() {
    res = tryCatch(system2("git", args = "--version"), error = function(e) e)
    st = attr(res, "status")
    if(is(res, "error") || (!is.null(st) && st > 0))
        FALSE
    else
        TRUE
    
}
