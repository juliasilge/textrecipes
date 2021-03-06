# Takes a data.frame (data) and replaces the columns with the names (names)
# and converts them from factor variable to character variables. Keeps 
# characters variables unchanged.
factor_to_text <- function(data, names) {
  for (i in seq_along(names)) {
    if (is.factor(data[, names[i], drop = TRUE]))
      data[, names[i]] <- as.character.factor(data[, names[i], drop = TRUE])
  }
  data
}

## This function takes the default arguments of `cl` (call object) and
## replaces them with the matching ones in `options` and
## remove any in `removals`
mod_call_args <- function(cl, args, removals = NULL) {
  if (!is.null(removals))
    for (i in removals)
      cl[[i]] <- NULL
    arg_names <- names(args)
    for (i in arg_names)
      cl[[i]] <- args[[i]]
    cl
}

check_list <- function (dat) {

  all_good <- vapply(dat, is.list, logical(1))

  if (!all(all_good))
    rlang::abort("All columns selected for the step should be a list-column")
  
  invisible(all_good)
}

# Takes a vector of character vectors and keeps (for keep = TRUE) the words
# or removes (for keep = FALSE) the words
word_list_filter <- function(x, words, keep) {

  if (!keep) {
    return(keep(x, !(x %in% words)))
  }
  else {
    return(keep(x, x %in% words))
  }
}
# same as word_list_filter but takes an list as input and returns a tibble with
# list-column.
word_tbl_filter <- function(x, words, keep) {
  tibble(
    map(x, word_list_filter, words, keep)
  )
}

# Takes a list of tokens and calculate the token count matrix
list_to_dtm <- function(word_list, dict) {
  i <- rep(seq_along(word_list), lengths(word_list))
  j <- match(unlist(word_list), dict)
  
  out <- sparseMatrix(i = i[!is.na(j)],  
                      j = j[!is.na(j)], 
                      dims = c(length(word_list), length(dict)),
                      x = 1)
  
  out@Dimnames[[2]] <- dict
  out
}
