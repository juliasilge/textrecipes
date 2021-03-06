#' Pretrained word embeddings of tokens
#'
#' `step_word_embeddings` creates a *specification* of a recipe step that will
#' convert a list of tokens into word-embedding dimensions by aggregating the
#' vectors of each token from a pre-trained embedding.
#'
#' @param recipe A recipe object. The step will be added to the sequence of
#'   operations for this recipe.
#' @param ... One or more selector functions to choose variables. For
#'   `step_word_embeddings`, this indicates the variables to be encoded into a
#'   list column. See [recipes::selections()] for more details. For the `tidy`
#'   method, these are not currently used.
#' @param role For model terms created by this step, what analysis role should
#'   they be assigned?. By default, the function assumes that the new columns
#'   created by the original variables will be used as predictors in a model.
#' @param columns A list of tibble results that define the encoding. This is
#'   `NULL` until the step is trained by [recipes::prep.recipe()].
#' @param embeddings A tibble of pre-trained word embeddings, such as those
#'   returned by the embedding_glove function function from the textdata 
#'   pacakge. The first column should contain tokens, and additional columns 
#'   should contain embeddings vectors.
#' @param aggregation A character giving the name of the aggregation function to
#'   use.
#' @param prefix A character string that will be the prefix to the resulting new
#'   variables. See notes below.
#' @param skip A logical. Should the step be skipped when the recipe is baked by
#'   [recipes::bake.recipe()]? While all operations are baked when
#'   [recipes::prep.recipe()] is run, some operations may not be able to be
#'   conducted on new data (e.g. processing the outcome variable(s)). Care
#'   should be taken when using `skip = TRUE` as it may affect the computations
#'   for subsequent operations.
#' @param id A character string that is unique to this step to identify it.
#' @param trained A logical to indicate if the recipe has been baked.
#'
#' @return An updated version of `recipe` with the new step added to the
#'   sequence of existing steps (if any).
#' @examples
#' library(recipes)
#'
#' embeddings <- tibble(
#'   tokens = c("the", "cat", "ran"),
#'   d1 = c(1, 0, 0),
#'   d2 = c(0, 1, 0),
#'   d3 = c(0, 0, 1)
#' )
#'
#' sample_data <- tibble(
#'   text = c(
#'     "The.",
#'     "The cat.",
#'     "The cat ran."
#'   ),
#'   text_label = c("fragment", "fragment", "sentence")
#' )
#'
#' rec <- recipe(text_label ~ ., data = sample_data) %>%
#'   step_tokenize(text) %>%
#'   step_word_embeddings(text, embeddings = embeddings)
#'   
#' obj <- rec %>%
#'   prep(training = sample_data)
#'
#' bake(obj, sample_data)
#'
#' tidy(rec, number = 2)
#' tidy(obj, number = 2)
#' @export
#' @details Word embeddings map words (or other tokens) into a high-dimensional
#'   feature space. This function maps pre-trained word embeddings onto the
#'   tokens in your data.
#'
#'   The argument `embeddings` provides the pre-trained vectors. Each dimension
#'   present in this tibble becomes a new feature column, with each column
#'   aggregated across each row of your text using the function supplied in the
#'   `aggregation` argument.
#'
#'   The new components will have names that begin with `prefix`, then the name
#'   of the aggregation function, then the name of the variable from the
#'   embeddings tibble (usually something like "d7"). For example, using the
#'   default "word_embeddings" prefix, the "sum" aggregation, and the GloVe
#'   embeddings from the textdata package (where the column names are `d1`,
#'   `d2`, etc), new columns would be `word_embeddings_sum_d1`,
#'   `word_embeddings_sum_d2`, etc.
#'
#' @seealso [step_tokenize()] [step_lda()]
step_word_embeddings <- function(recipe,
                            ...,
                            role = "predictor",
                            trained = FALSE,
                            columns = NULL,
                            embeddings,
                            aggregation = c("sum", "mean", "min", "max"),
                            prefix = "w_embed",
                            skip = FALSE,
                            id = rand_id("word_embeddings")) {
  # Validate the special inputs here to make sure nothing goes haywire further
  # downstream.
  if (
    !tibble::is.tibble(embeddings) ||
    !any(inherits(embeddings[[1]], c("character", "factor"), which = TRUE)) ||
    ncol(embeddings) == 1 ||
    !all(map_lgl(embeddings[,2:ncol(embeddings)], is.numeric))
  ) {
    embeddings_message <- paste(
      "embeddings should be a tibble with 1 character or factor column and",
      "additional numeric columns."
    )
    rlang::abort(
      embeddings_message,
      .subclass = "bad_embeddings"
    )
  }
  
  # For now aggregation must be the name of one of the listed aggregation
  # functions. I'm having them pass it in as character to avoid more complicated
  # checks.
  aggregation <- match.arg(aggregation)
  
  add_step(
    recipe,
    step_word_embeddings_new(
      terms = ellipse_check(...),
      role = role,
      trained = trained,
      columns = columns,
      embeddings = embeddings,
      aggregation = aggregation,
      prefix = prefix,
      skip = skip,
      id = id
    )
  )
}

step_word_embeddings_new <- function(terms, role, trained, columns, embeddings, 
                                     aggregation, prefix, skip, id) {
  recipes::step(
    subclass = "word_embeddings",
    terms = terms,
    role = role,
    trained = trained,
    columns = columns,
    embeddings = embeddings,
    aggregation = aggregation,
    prefix = prefix,
    skip = skip,
    id = id
  )
}

#' @export
prep.step_word_embeddings <- function(x, training, info = NULL, ...) {
  col_names <- terms_select(x$terms, info = info)
  
  check_list(training[, col_names])
  
  step_word_embeddings_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    columns = col_names,
    embeddings = x$embeddings,
    aggregation = x$aggregation,
    prefix = x$prefix,
    skip = x$skip,
    id = x$id
  )
}

#' @export
bake.step_word_embeddings <- function(object, new_data, ...) {
  col_names <- object$columns
  # for backward compat
  
  for (i in seq_along(col_names)) {
    embeddings_columns <- map_dfr(
      new_data[, col_names[i], drop = TRUE],
      aggregate_embeddings,
      embeddings = object$embeddings,
      aggregation = object$aggregation,
      prefix = object$prefix
    )
    
    new_data <- bind_cols(new_data, embeddings_columns)
    
    new_data <-
      new_data[, !(colnames(new_data) %in% col_names[i]), drop = FALSE]
  }
  
  as_tibble(new_data)
}

aggregate_embeddings <- function(tokens, embeddings, aggregation, prefix) {
  aggregation_function <- switch(
    aggregation,
    sum = sum,
    mean = mean,
    min = min,
    max = max
  )
  embeddings_token_colname <- colnames(embeddings)[[1]]
  
  # Add a "NA" token if there isn't one. For now I'm going to set this to all 0,
  # we may want to revise this with more use cases.
  if (!any(is.na(embeddings[[1]]))) {
    embeddings[nrow(embeddings) + 1, 1] <- NA_character_
    embeddings[nrow(embeddings), -1] <- 0
  }
  
  # Deal with missing tokens.
  missing_tokens <- setdiff(tokens, embeddings[[1]])
  if (length(missing_tokens) > 0) {
    warning_msg <- paste(
      "Tokens missing from embeddings tibble:",
      paste(missing_tokens, collapse = ", ")
    )
    if (length(setdiff(tokens, missing_tokens)) == 0) {
      rlang::abort(
        warning_msg,
        .subclass = "all_tokens_missing_embeddings"
      )
    } else {
      rlang::warn(
        warning_msg,
        .subclass = "missing_tokens"
      )
    }
  }
  
  these_embeddings <- select(
    inner_join(
      tibble(tokens = tokens),
      embeddings, 
      by = c("tokens" = embeddings_token_colname)
    ), -"tokens"
  )
  
  # Rename columns using the supplied pattern.
  these_embeddings <- rename_all(
    these_embeddings, 
    ~ paste(prefix, aggregation, ., sep = "_")
  )
  
  # Aggregate as requested.
  summarize_all(these_embeddings, aggregation_function)
}

#' @export
print.step_word_embeddings <- function(x, 
                                       width = max(20, options()$width - 30),
                                       ...) {
  cat("Word embeddings aggregated from ", sep = "")
  printer(x$columns, x$terms, x$trained, width = width)
  invisible(x)
}

#' @rdname step_word_embeddings
#' @param x A `step_word_embeddings` object.
#' @export
tidy.step_word_embeddings <- function(x, ...) {
  if (is_trained(x)) {
    res <- tibble(terms = x$terms,
                  embeddings_rows = nrow(x$embeddings),
                  aggregation = x$aggregation)
  } else {
    term_names <- sel2char(x$terms)
    res <- tibble(terms = term_names,
                  embeddings_rows = nrow(x$embeddings),
                  aggregation = x$aggregation)
  }
  res$id <- x$id
  res
}