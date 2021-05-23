test_that('The system loads the catalogue', {
  df <- dp_list_datasets()

  expect_true(tibble::is_tibble(df))
  expect_true(nrow(df) > 1)

  expect_equal(ncol(df), 8)

  expect_error(dp_list_datasets('asd'))
})


test_that('The package retrieves urls',{
  df <- dp_list_datasets()
  n <- sample(1:nrow(df), 1)
  data_name <- df$data_name[n]
  data_url <- df$data_url[n]

  expect_error(dp_get_page_url())
  expect_error(dp_get_page_url(""))
  expect_error(dp_get_page_url("asasd"))

  expect_equal(dp_get_page_url(data_name), data_url)
})


test_that('URLs are processed', {
  df <- dp_list_datasets()
  n <- sample(1:nrow(df), 1)
  data_name <- df$data_name[n]
  data_url <- df$data_url[n]
  urls <- dp_process_page_url(data_url)

  expect_equal(length(urls), 3)

  expect_true('page_url' %in% names(urls))
  expect_true('data_url' %in% names(urls))
  expect_true('info_url' %in% names(urls))
})


test_that('A dataset is retrieved', {
  df <- dp_list_datasets()
  n <- sample(1:nrow(df), 1)
  data_name <- df$data_name[n]
  data_url <- df$data_url[n]

  data_set <- dp_get_dataset(data_name, data_url)

  expect_equal(length(data_set), 4)
  expect_equal(dp_get_dataset(data_name), data_set)

  expect_true('set_name' %in% names(data_set))
  expect_true('set_url' %in% names(data_set))
  expect_true('raw_data' %in% names(data_set))
  expect_true('raw_info' %in% names(data_set))

  expect_error(dp_get_dataset('asd'))
  expect_error(dp_get_dataset(data_name, 'asd'))
})


test_that('Data can return a table', {
  df <- dp_list_datasets()
  n <- sample(1:nrow(df), 1)
  data_name <- df$data_name[n]
  data_url <- df$data_url[n]
  data_set <- dp_get_dataset(data_name, data_url)

  data_table <- dp_load_dataset(data_set)

  expect_true(tibble::is_tibble(data_table))
})
