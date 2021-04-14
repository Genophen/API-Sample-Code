IN_DIR='/var/sftp/cigna_data/incoming'
if [[ $1  -eq '' ]]
then
   echo 'Need date stamp'
   exit 1
else
   DT_STAMP=$1
fi
for FILE_NAME in `ls ${IN_DIR}/*.txt.gpg`
do
   COPY_RAW_FILE=0
   BASE_NAME=`basename ${FILE_NAME}`
   if [[ ${BASE_NAME} == *${DT_STAMP}* ]]
   then
      echo "Matched"
      #echo ${BASE_NAME}
      IFS='\.' read -ra ADDR <<< ${BASE_NAME}
      OUT_FILE="${ADDR[0]}.csv"
      echo ${OUT_FILE}
      gpg -d ${FILE_NAME} >"incoming/${OUT_FILE}"
      delim='|'
      case ${OUT_FILE} in
         *MA_AZ_Claims*)
            S3_BUCKET=s3://basehealth-data/cigna/inbound/claims/datedInboundClaims/
            S3_RAW_BUCKET=s3://basehealth-data/cigna/inbound/claims/sftp/
	    COPY_RAW_FILE=1
            ;;
         *MA_AZ_Membership*)
            S3_BUCKET=s3://basehealth-data/cigna/inbound/membership/
            ;;
         *_AZ_Labs*)
            S3_BUCKET=s3://basehealth-data/cigna/inbound/labs/
	    delim=','
            ;;
         *_AZ_RxClaims*)
            S3_BUCKET=s3://basehealth-data/cigna/inbound/rx/
            ;;
         *)
            echo "DEFAULT"
      esac
      echo ${S3_BUCKET}
      let file_length=`wc -l "incoming/${OUT_FILE}"|cut -d" " -f1`-1
      echo "file_date" >/tmp/$$
      fmtd_date=${DT_STAMP:0:4}-${DT_STAMP:4:2}-${DT_STAMP:6:2}
      yes ${fmtd_date} | head -n ${file_length} >>/tmp/$$
      paste -d${delim} /tmp/$$ "incoming/${OUT_FILE}" > "incoming/dtd_${OUT_FILE}"
      aws s3 cp "incoming/dtd_${OUT_FILE}" ${S3_BUCKET}
      if [[ ${COPY_RAW_FILE} -eq 1 ]]
      then
        aws s3 cp "incoming/${OUT_FILE}" ${S3_RAW_BUCKET}
      fi
      rm /tmp/$$ "incoming/${OUT_FILE}"
   fi
done
