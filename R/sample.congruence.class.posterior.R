#' Stochastic exploration of congruent models for all samples in the posterior
#' 
#' @description 
#' This function takes a posterior sample as input: a list of ACDC objects. 
#' It will then iterate over the samples, and for each posterior sample it will
#' sample from the posterior class. It will sample using the \code{\link{sample.basic.models}}
#' function, and all additional parameters are passed to \code{\link{sample.basic.models}}.
#'
#' @param posterior a list of ACDC model objects
#' @inheritParams sample.congruence.class
#' @inheritDotParams sample.basic.models
#'
#' @inherit sample.congruence.class return
#' @export
#'
#' @examples 
#' data(primates_ebd_log)
#' 
#' posterior <- read.RevBayes(primates_ebd_log, max_t = 65, n_samples = 20)
#' 
#' samples <- sample.congruence.class.posterior(posterior, 
#'                                              num.samples = 20,
#'                                              rate.type = "extinction",
#'                                              rate0.median = 0.1,
#'                                              model = "MRF",
#'                                              max.rate = 1.0)
#' 
#' print(samples)
sample.congruence.class.posterior <- function(posterior,
                                              num.samples, 
                                              rate.type="extinction", 
                                              ...){
  

  pb <- txtProgressBar(min = 1, max = length(posterior), style = 3)  
  res <- list()
  
  for(i in seq_along(posterior)){
    times <- posterior[[i]]$times
    num.epochs <- length(posterior[[i]]$times)
    
    if(rate.type == "speciation"){
      sample.extinction.rates <- NULL
      sample.speciation.rates <- function () {sample.basic.models(times = times, rate0 = posterior[[i]]$lambda(0.0), ...)}
      
    }else if(rate.type == "extinction"){
      sample.extinction.rates <- function() {sample.basic.models(times = times, ...)}
      sample.speciation.rates <- NULL
      
    }else if(rate.type == "both"){
      sample.extinction.rates <- function() {sample.basic.models(times = times, ...)}
      sample.speciation.rates <- function() {sample.basic.models(times = times, rate0 = posterior[[i]]$lambda(0.0), ...)}
      
    }else{
      stop("rate.type must be either \"speciation\", \"extinction\", or \"both\".")
    }

    cg <- sample.congruence.class(posterior[[i]],
                                  num.samples = num.samples,
                                  rate.type = rate.type,
                                  sample.speciation.rates = sample.speciation.rates,
                                  sample.extinction.rates = sample.extinction.rates)
    
    
    res[[i]] <- cg
    setTxtProgressBar(pb, i)
  }
  close(pb)
  
  names(res) <- paste0("posterior", seq_along(res))
  class(res) <- c("ACDCsets", "list")
  return(res)
}