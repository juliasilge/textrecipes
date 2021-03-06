% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenfilter.R
\name{step_tokenfilter}
\alias{step_tokenfilter}
\alias{tidy.step_tokenfilter}
\title{Filter the tokens based on term frequency}
\usage{
step_tokenfilter(
  recipe,
  ...,
  role = NA,
  trained = FALSE,
  columns = NULL,
  max_times = Inf,
  min_times = 0,
  percentage = FALSE,
  max_tokens = 100,
  res = NULL,
  skip = FALSE,
  id = rand_id("tokenfilter")
)

\method{tidy}{step_tokenfilter}(x, ...)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the
sequence of operations for this recipe.}

\item{...}{One or more selector functions to choose variables.
For `step_tokenfilter`, this indicates the variables to be encoded
into a list column. See [recipes::selections()] for more
details. For the `tidy` method, these are not currently used.}

\item{role}{Not used by this step since no new variables are
created.}

\item{trained}{A logical to indicate if the recipe has been
baked.}

\item{columns}{A list of tibble results that define the
encoding. This is `NULL` until the step is trained by
[recipes::prep.recipe()].}

\item{max_times}{An integer. Maximal number of times a word can appear
before getting removed.}

\item{min_times}{An integer. Minimum number of times a word can appear
before getting removed.}

\item{percentage}{A logical. Should max_times and min_times be interpreded 
as a percentage instead of count.}

\item{max_tokens}{An integer. Will only keep the top max_tokens tokens
after filtering done by max_times and min_times. Defaults to 100.}

\item{res}{The words that will be keep will be stored here once 
this preprocessing step has be trained by [prep.recipe()].}

\item{skip}{A logical. Should the step be skipped when the
recipe is baked by [recipes::bake.recipe()]? While all
operations are baked when [recipes::prep.recipe()] is run, some
operations may not be able to be conducted on new data (e.g.
processing the outcome variable(s)). Care should be taken when
using `skip = TRUE` as it may affect the computations for
subsequent operations.}

\item{id}{A character string that is unique to this step to identify it.}

\item{x}{A `step_tokenfilter` object.}
}
\value{
An updated version of `recipe` with the new step added
 to the sequence of existing steps (if any).
}
\description{
`step_tokenfilter` creates a *specification* of a recipe step that
 will convert a list of tokens into a list where the tokens are filtered
 based on frequency.
}
\details{
This step allow you to limit the tokens you are looking at by filtering
on their occurance in the corpus. You are able to exclude tokens if they
appear too many times or too fews times in the data. It can be specified
as counts using `max_times` and `min_times` or as percentages by setting
`percentage` as `TRUE`. In addition one can filter to only use the top
`max_tokens` used tokens. If `max_tokens` is set to `Inf` then all the tokens
will be used. This will generally lead to very large datasets when then 
tokens are words or trigrams. A good strategy is to start with a low token 
count and go up according to how much RAM you want to use.

It is strongly advised to filter before using [step_tf] or [step_tfidf] to 
limit the number of variables created.
}
\examples{
library(recipes)

data(okc_text)

okc_rec <- recipe(~ ., data = okc_text) \%>\%
  step_tokenize(essay0) \%>\%
  step_tokenfilter(essay0) 
  
okc_obj <- okc_rec \%>\%
  prep(training = okc_text, retain = TRUE)

juice(okc_obj, essay0) \%>\% 
  slice(1:2)

juice(okc_obj) \%>\% 
  slice(2) \%>\% 
  pull(essay0)

tidy(okc_rec, number = 2)
tidy(okc_obj, number = 2)
}
\seealso{
[step_untokenize()]
}
