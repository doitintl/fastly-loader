#/bin/bash

if [[ $# -eq 0 ]] ; then
 echo Missing DATE argument in a form of YYYY-MM-DD
 exit
fi

# setting the default project as a safty measure
gcloud config set project taboola-cdn-logs &> /dev/null

# listing GCS folders for a given day
FOLDERS=( $(gsutil ls -d gs://taboola-cdn-logs-fastly-trc/$1*) )
echo Launching ${#FOLDERS[@]} BigQuery load jobs

# enumerating thru all folders and subfolders 01-08
for folder in "${FOLDERS[@]}"
do
   : 
for i in `seq 1 8`;
        do
                echo ֿֿ"Creating loading job for folder ${folder}0${i}/*.gz" 
                bq load --max_bad_records 100 --source_format NEWLINE_DELIMITED_JSON --schema fastly.json --nosynchronous_mode fastly_logs."${1//-/_}" ${folder}0${i}/*.gz
        done 

done

echo "All BigQuery Loading Jobs are launched! Please wait 15 minutes before sending queries."