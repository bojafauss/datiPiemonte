# What it does

This is a small package to load data from the dati.piemonte.it portal in your R session.
Currently supports only data hosted on the Yucca platform.

# How to install

```
devtools::install_github(
  repo = "bojafauss/datiPiemonte",
  subdir = "datiPiemonte"
)

library(datiPiemonte)
```

# How to use

Get a list of available data sets

```
catalogue <- dp_list_datasets()
```

Get the data and metadata of a specific dataset

```
data_set <- dp_get_dataset(catalogue$data_name[1]) # downloads data and metadata
data_set <- dp_load_dataset(data_set) # attempt to auto import, may fail
```

# Etiquette

There are no timeouts in the package, I trust you to be nice to the platform owners.
Do NOT hammer the site / api.

# Contribute

Make a pull request.
I will set up some Github actions eventually.

Your code should be able to pass the build-helper.sh file without failing. ;)


