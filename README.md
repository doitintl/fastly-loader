# Fastly Logs Loader to BigQuery
Loading Fastly logs from Google Cloud Storage bucket to BigQuery

**Usage**

./load-fastly.sh --dataset={datasetname} --date={YYYY-MM-DD}

**Example**

The following will load the day of *2018-07-02* into dataset *mydataset*

```
./load-fastly.sh --dataset=mydataset --date=2018-07-02
```
