#' Set basic options for calls to Web of Science API
#'
#' @param wos_base_folder Base folder where all responses from Web of Science
#'   API calls are cached
#' @param wos_api_key Web of Science API.
#'
#' @returns Invisibly returns all settings as a list.
#' @export
#'
#' @examples
#' wos_set(
#'   wos_base_folder = "WoS_cache",
#'   wos_api_key = "SuperSecretKey"
#' )
#'
#' wos_settings <- wos_set()
#'
#' wos_settings
wos_set <- function(wos_base_folder = NULL,
                    wos_api_key = NULL) {
  if (is.null(wos_base_folder)) {
    wos_base_folder <- Sys.getenv("scopusscoper_wos_base_folder")
  } else {
    Sys.setenv(scopusscoper_wos_base_folder = as.character(wos_base_folder))
  }

  if (is.null(wos_api_key)) {
    wos_api_key <- Sys.getenv("scopusscoper_wos_api_key")
  } else {
    Sys.setenv(scopusscoper_wos_api_key = as.character(wos_api_key))
  }

  invisible(list(
    wos_base_folder = wos_base_folder,
    wos_api_key = wos_api_key
  ))
}
