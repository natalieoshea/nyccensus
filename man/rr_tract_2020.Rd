% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{rr_tract_2020}
\alias{rr_tract_2020}
\title{Daily Response Rate Data for the 2020 Census in New York City}
\format{
A data frame with 383,541 rows and 9 variables:
\describe{
\item{RESP_DATE}{response date (format: YYYY-MM-DD)}
\item{GEO_ID}{census tract (2020 geography)}
\item{BORO}{borough}
\item{NEIGHBORHOOD}{neighborhood}
\item{TRACT}{tract}
\item{CRRALL}{cumulative response rate}
\item{CRRINT}{cumulative response rate (internet-only)}
\item{DRRALL}{daily response rate}
\item{DRRINT}{daily response rate (internet-only)}
}
}
\usage{
rr_tract_2020
}
\description{
A dataset containing daily response rate data (March 20 to October 17) reported
by the US Census Bureau for the 2020 Census in NYC census tracts (2020 geography).
The variables are as follows:
}
\keyword{datasets}
