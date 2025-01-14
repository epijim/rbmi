% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mmrm.R
\name{fit_mmrm_multiopt}
\alias{fit_mmrm_multiopt}
\title{Fit an MMRM model via multiple optimizers}
\usage{
fit_mmrm_multiopt(..., optimizer)
}
\arguments{
\item{...}{Additional arguments passed onto \code{\link[=fit_mmrm]{fit_mmrm()}}}

\item{optimizer}{A character vector or a named list. See details.}
}
\description{
The function attempts to fit a MMRM model using the optimizer as specified in \code{optimizer}
If \code{optimizer} is of length > 1 then it will loop through all the values until one of them is able
to converge. That is to say if a fit fails to converge it will move onto the next value of \code{optimizer} and
try again.
}
\details{
If \code{optimizer} is a list then the names of the list will be taken to be the required \code{optimizer}
with the contents of that element being used as the initial values.  This functionality
can be used to try and fit the model using the same optimizer at multiple different starting
values e.g.:\preformatted{fit_mmrm_multiopt(
    ...,
    optimizer = list(
        "L-BFGS-B" = list(beta = c(1,2,3), theta = c(9,8,7)),
        "L-BFGS-B" = list(beta = c(5,6,7), theta = c(10,11,12)),
    )
)
}

See \code{\link[stats:optim]{stats::optim()}} for a list of the available optimizers that can be used
}
\seealso{
\code{\link[=fit_mmrm]{fit_mmrm()}}
}
