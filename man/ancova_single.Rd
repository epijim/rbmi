% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ancova.R
\name{ancova_single}
\alias{ancova_single}
\title{Implements an Analysis of Covariance (ANCOVA)}
\usage{
ancova_single(data, outcome, group, covariates)
}
\arguments{
\item{data}{The \code{data.frame} containing all of the data required for the model.}

\item{outcome}{Character, the name of the outcome variable in \code{data}.}

\item{group}{Character, the name of the group variable in \code{data}.}

\item{covariates}{Character vector containing the name of any additional covariates
to be included in the model as well as any interaction terms.}
}
\description{
Performance analysis of covariance. See \code{\link[=ancova]{ancova()}} for full details.
}
\details{
\itemize{
\item \code{group} must be a factor variable with only 2 levels.
\item \code{outcome} must be a continuous numeric variable.
}
}
\examples{
\dontrun{
iris2 <- iris[ iris$Species \%in\% c("versicolor", "virginica"), ]
iris2$Species <- factor(iris2$Species)
ancova_single(iris2, "Sepal.Length", "Species", c("Petal.Length * Petal.Width"))
}
}
\seealso{
\code{\link[=ancova]{ancova()}}
}
