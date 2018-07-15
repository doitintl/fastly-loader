#/bin/bash

# print usage information
function usage()
{
    echo "Load Fastly logs from Google Cloud Storage to BigQuery"
    echo "Usage:"
    echo "\t--help"
    echo "\t--dataset=$DATASET"
    echo "\t--date=$DATE"
}

# check if both arguments are provided
if [ $# -ne 2 ]; then
    usage
    exit 1
fi

# parse arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --help)
            usage
            exit
            ;;
        --dataset)
            DATASET=$VALUE
            ;;
        --date)
            DATE=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# check whether the schema file exists
schema="fastly.json"
if [ ! -f "$schema" ]
then
    echo "$0: Schema definition file '${schema}' not found.";exit 1;
fi

# create dataset if not exists
bq ls | grep $DATASET &> /dev/null
if [ $? == 0 ]; then
   echo Found dataset $DATASET
else
   echo dataset $DATASET is not found, creating the dataset
   bq mk -d --data_location=US $DATASET
fi


# setting the default project as a safty measure
gcloud config set project taboola-cdn-logs &> /dev/null

# listing GCS folders for a given day
FOLDERS=( $(gsutil ls -d gs://taboola-cdn-logs-fastly-trc/$DATE*) )

# Calculating the number of BigQuery jobs required
echo Launching ${#FOLDERS[@]} BigQuery loading jobs for date $DATE to dataset $DATASET

# enumerating thru all folders and subfolders 01-08
for folder in "${FOLDERS[@]}"
 do
 	  zero="00"
      hour=$(echo $folder | cut -d'T' -f 2 | head -c 2)

      bq load --max_bad_records 20000 --source_format NEWLINE_DELIMITED_JSON --noautodetect --schema fastly.json --nosynchronous_mode $DATASET."${DATE//-/_}"_$hour$zero ${folder}*.gz

done

echo "All BigQuery Loading Jobs are launched! Please wait 15 minutes before sending queries."
