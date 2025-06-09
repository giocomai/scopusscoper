#' Search Web of Science starter API
#'
#' @param query Web of Science query. See examples and official documentation.
#' @param filename Custom file name for caching the query, defaults to NULL. If
#'   NULL, file name is derived from the query.
#' @inheritParams wos_set
#'
#' @returns A list with all responses.
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   # Remember to set the API key with wos_set()
#'   wos_search(query = "TS='higher education' AND FPY=2025")
#' }
#' }
wos_search <- function(query,
                       filename = NULL,
                       wos_base_folder = NULL,
                       wos_api_key = NULL) {
  wos_settings <- wos_set(
    wos_base_folder = wos_base_folder,
    wos_api_key = wos_api_key
  )

  if (is.null(filename)) {
    filename <- query |>
      stringr::str_replace_all(pattern = "'| ", replacement = "_") |>
      stringr::str_replace_all(pattern = "[[:punct:]]", replacement = "_") |>
      stringr::str_replace_all(pattern = "=", replacement = "_") |>
      fs::path_sanitize() |>
      fs::path_ext_set("rds")
  }

  search_combo_file <- fs::path(wos_settings[["wos_base_folder"]], filename)

  if (fs::file_exists(search_combo_file)) {
    return(readr::read_rds(file = search_combo_file))
  }

  base_url <- "https://api.clarivate.com/apis/wos-starter/v1/documents"

  base_cache_folder <- fs::path(
    wos_settings[["wos_base_folder"]],
    filename |>
      fs::path_ext_remove()
  ) |>
    fs::dir_create()

  current_file <- fs::path(base_cache_folder, "1.rds")

  if (!fs::file_exists(current_file)) {
    api_request <- httr2::request(base_url = base_url) |>
      httr2::req_headers(
        "Accept" = "application/json",
        `X-ApiKey` = wos_settings[["wos_api_key"]]
      ) |>
      httr2::req_url_query(
        db = "WOS",
        limit = 50,
        q = query,
        page = 1
      ) |>
      httr2::req_error(is_error = \(resp) FALSE)

    response <- httr2::req_perform(api_request)

    response_json <- response |>
      httr2::resp_body_json()

    attr(response_json, "query") <- query
    attr(response_json, "page") <- response_json$metadata$page
    attr(response_json, "total_results") <- response_json$metadata$total
    attr(response_json, "date") <- response$headers$date
    attr(response_json, "retrieved_at") <- Sys.time()

    saveRDS(object = response_json, file = current_file)
  }

  response_json <- readr::read_rds(current_file)

  total_results <- response_json$metadata$total |>
    as.numeric()

  requests_required <- ((total_results - 1) %/% 50) + 1

  cli::cli_inform(message = "Total results: {scales::number(total_results)}")

  purrr::walk(
    .progress = "Retrieving results",
    .x = 1:requests_required,
    .f = \(current_page) {
      current_file <- fs::path(base_cache_folder, current_page) |>
        fs::path_ext_set(ext = "rds")

      if (!fs::file_exists(current_file)) {
        api_request <- httr2::request(base_url = base_url) |>
          httr2::req_headers(
            "Accept" = "application/json",
            `X-ApiKey` = wos_settings[["wos_api_key"]]
          ) |>
          httr2::req_url_query(
            db = "WOS",
            limit = 50,
            q = query,
            page = current_page
          ) |>
          httr2::req_error(is_error = \(resp) FALSE)

        response <- httr2::req_perform(api_request)

        response_json <- response |>
          httr2::resp_body_json()

        attr(response_json, "query") <- query
        attr(response_json, "page") <- response_json$metadata$page
        attr(response_json, "total_results") <- response_json$metadata$total
        attr(response_json, "date") <- response$headers$date
        attr(response_json, "retrieved_at") <- Sys.time()

        saveRDS(object = response_json, file = current_file)
        Sys.sleep(1)
      }
    }
  )


  files_v <- tibble::tibble(
    available_files = fs::dir_ls(path = fs::path(base_cache_folder))
  ) |>
    dplyr::mutate(id = available_files |>
      fs::path_file() |>
      fs::path_ext_remove() |>
      as.numeric()) |>
    dplyr::arrange(id) |>
    dplyr::pull(available_files)

  all_results_l <- purrr::map(
    .progress = "Merging results...",
    .x = files_v,
    .f = function(current_file) {
      current_result <- readr::read_rds(current_file)
      current_result |>
        purrr::pluck("hits")
    }
  ) |>
    purrr::list_c()

  attr(all_results_l, "query") <- query
  attr(all_results_l, "total_results") <- response_json$metadata$total
  attr(all_results_l, "retrieved_at") <- Sys.time()

  saveRDS(
    object = all_results_l,
    file = search_combo_file
  )

  all_results_l
}
