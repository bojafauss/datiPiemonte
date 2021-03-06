#' Get the availabe datasets on dati.piemonte
#'
#' @description
#' This functions retrieves the file that list the open data on the portal and reads it.
#' Currently only YUCCA hosted datasets are supported, if you want to add more, do a pull request.
#' You can use the data_url for further calls, of just the name, is up to you.
#'
#' @return A tibble
#'
#' @export
#'
#' @examples
#' dp_list_datasets()

dp_list_datasets <- function(){
  catalogue <- readr::read_delim(
    'https://www.dati.piemonte.it/api/datasets/summary',
    delim =';',
    skip = 1,
    col_names = c('data_theme', 'data_name', 'data_owner', 'creation_date', 'last_update_date', 'data_url', 'refresh_rate', 'source'),
    col_types = 'cccccccc')

  catalogue$creation_date  <- as.Date(catalogue$creation_date)
  catalogue$last_update_date <- as.Date(catalogue$last_update_date)

  catalogue[grep('YUCCA', catalogue$source), ]
}


#' Get the url of a dataset given the name
#'
#' @description
#' This is an internal functionality.
#' Given the name of a dataset it downloads the catalogue and check for the corresponding url.
#'
#' @param datasetname the name of the dataset, as it appears in the catalogue
#'
#' @return A string
#'
#' @examples
#' if(FALSE){dp_get_page_url("datasetname from dp_list_datasets()")}

dp_get_page_url <- function(datasetname){
  catalogue <- subset(dp_list_datasets(), data_name == datasetname)

  assertthat::assert_that(nrow(catalogue) != 0, msg = 'Dataset not found')
  assertthat::assert_that(nrow(catalogue) <= 1, msg = 'Key not unique')

  catalogue$data_url[1]
}


#' Make the download and documentation links from a page url
#'
#' @description
#' This is an internal functionality.
#' Given a page url it creates urls to download data and metadata.
#' Currently only supports the YUCCA hosted datasets.
#'
#' @param page_url the url of the dataset page on the datipiemonte.it portal
#'
#' @return A list with 3 urls
#'
#' @examples
#' if(FALSE){dp_process_page_url(page_url)}

dp_process_page_url <- function(page_url){
  data_set_string <- stringr::str_extract(page_url, '(?<=smartdatanet.it_)(.*)')
  data_set_yucca_id <- stringr::str_extract(data_set_string, '[^_]+$')

  assertthat::assert_that(!is.na(data_set_string), msg = 'name is invalid')
  assertthat::assert_that(!is.na(data_set_yucca_id), msg = 'name is invalid')

  list(
    page_url = page_url,
    data_url = paste0('http://api.smartdatanet.it/api/',data_set_string,'/download/',data_set_yucca_id,'/all'),
    info_url = paste0('http://api.smartdatanet.it/metadataapi/api/v02/detail/',data_set_string))
}


#' Download a dataset given the name and optionally the url
#'
#' @description
#' Given a dataset name, and optionally the url in the dati.piemonte portal it downloads the raw data.
#' It is left to the user what to do with those.
#'
#' @export
#'
#' @param set_name a string
#' @param set_url a string, optional
#'
#' @return A list with a csv file and a json of extra info
#'
#' @examples
#' if(FALSE){dp_get_dataset('name_here')}
#' if(FALSE){dp_get_dataset('name_here', 'url_here')}
#'
dp_get_dataset <- function(set_name, set_url = ""){

  if(set_url == ""){
    set_url <- dp_get_page_url(set_name)
  }

  urls <- dp_process_page_url(set_url)

  list(
    set_name = set_name,
    set_url = urls$page_url,
    raw_data = httr::GET(urls$data_url) %>% httr::content('text'),
    raw_info = httr::GET(urls$info_url) %>% httr::content('text'))

}

#' Cleans and load a dataset object returned from dp_get_dataset
#' To be used if the user wants to avoid manual inspection
#' May fail
#'
#' @description
#' This is a utility for lazy people.
#' It takes as input a list outputted by dp_get_dataset and uses the metadata to define the names.
#' Columns encoding is guessed.
#' The separator is guessed to be a semicolon, can be wrong.
#' If you want to contribute in making this function better, do a pull request.
#'
#' @export
#'
#' @return A tibble
#'
#' @param raw_dataset_object the output of dp_get_dataset
#' @param delim the delimiter of the data, if not semicolon
#' @param ... other parameters to be passed to read_delim
#'
#' @examples
#' if(FALSE){dataset_name %>% dp_get_dataset %>% dp_load_dataset}

dp_load_dataset <- function(raw_dataset_object, delim = ';', ...){
  dataset_metadata <- raw_dataset_object$raw_info %>%
    jsonlite::fromJSON() %>%
    {.$components} %>%
    as.data.frame()

  dataset_col_names <- dataset_metadata[order(dataset_metadata$inOrder),]$name

  readr::read_delim(
    raw_dataset_object$raw_data,
    delim = delim,
    skip = 1,
    col_names = dataset_col_names,
    ...)
}
