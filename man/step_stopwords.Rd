% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stopwords.R
\name{step_stopwords}
\alias{step_stopwords}
\alias{tidy.step_stopwords}
\title{Filtering of stopwords from a list-column variable}
\usage{
step_stopwords(
  recipe,
  ...,
  role = NA,
  trained = FALSE,
  columns = NULL,
  language = "en",
  keep = FALSE,
  stopword_source = "snowball",
  custom_stopword_source = NULL,
  skip = FALSE,
  id = rand_id("stopwords")
)

\method{tidy}{step_stopwords}(x, ...)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the
sequence of operations for this recipe.}

\item{...}{One or more selector functions to choose variables.
For `step_stopwords`, this indicates the variables to be encoded
into a list column. See [recipes::selections()] for more
details. For the `tidy` method, these are not currently used.}

\item{role}{Not used by this step since no new variables are
created.}

\item{trained}{A logical to indicate if the recipe has been
baked.}

\item{columns}{A list of tibble results that define the
encoding. This is `NULL` until the step is trained by
[recipes::prep.recipe()].}

\item{language}{A character to indicate the langauge of stopwords 
by ISO 639-1 coding scheme.}

\item{keep}{A logical. Specifies whether to keep the stopwords or discard
them.}

\item{stopword_source}{A character to indicate the stopwords source as 
listed in `stopwords::stopwords_getsources`.}

\item{custom_stopword_source}{A character vector to indicate a custom 
list of words that cater to the users specific problem.}

\item{skip}{A logical. Should the step be skipped when the
recipe is baked by [recipes::bake.recipe()]? While all
operations are baked when [recipes::prep.recipe()] is run, some
operations may not be able to be conducted on new data (e.g.
processing the outcome variable(s)). Care should be taken when
using `skip = TRUE` as it may affect the computations for
subsequent operations.}

\item{id}{A character string that is unique to this step to identify it.}

\item{x}{A `step_stopwords` object.}
}
\value{
An updated version of `recipe` with the new step added
 to the sequence of existing steps (if any).
}
\description{
`step_stopwords` creates a *specification* of a recipe step that
 will filter a list of tokens for stopwords(keep or remove).
}
\details{
Stop words are words which sometimes are remove before natural language
processing tasks. While stop words usually refers to the most common 
words in the laguange there is no universal stop word list. 

The argument `custom_stopword_source` allows you to pass a character vector
to filter against. With the `keep` argument one can specify to keep the 
words instead of removing thus allowing you to select words with a 
combination of these two arguments.
}
\examples{
library(recipes)

data(okc_text)

okc_rec <- recipe(~ ., data = okc_text) \%>\%
  step_tokenize(essay0) \%>\%
  step_stopwords(essay0) 
  
okc_obj <- okc_rec \%>\%
  prep(training = okc_text, retain = TRUE)

juice(okc_obj, essay0) \%>\% 
  slice(1:2)

juice(okc_obj) \%>\% 
  slice(2) \%>\% 
  pull(essay0) 
  
tidy(okc_rec, number = 2)
tidy(okc_obj, number = 2)
# With a custom stopwords list

okc_rec <- recipe(~ ., data = okc_text) \%>\%
  step_tokenize(essay0) \%>\%
  step_stopwords(essay0, custom_stopword_source = c("twice", "upon"))
okc_obj <- okc_rec \%>\%
  prep(traimomg = okc_text, retain = TRUE)
  
juice(okc_obj) \%>\%
  slice(2) \%>\%
  pull(essay0) 
}
\seealso{
[step_stem()] [step_tokenfilter()] [step_tokenize()]
}
