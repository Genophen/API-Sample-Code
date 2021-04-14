echo $1 >>/tmp/change.txt
FILE_NAME=$1
IN_DIR='/var/sftp/cigna_data/incoming'
IN_FILE=${IN_DIR}/${FILE_NAME}
#echo $IN_FILE >>/tmp/change.txt
#echo `who` >>/tmp/change.txt
IFS='\.' read -ra ADDR <<< ${FILE_NAME}
OUT_FILE="${ADDR[0]}.csv"
#echo ${OUT_FILE} >>/tmp/change.txt
#echo `env` >>/tmp/change.txt
#/usr/bin/gpg --version
#/usr/bin/gpg --passphrase HxW5L9xx --decrypt ${IN_FILE} >/tmp/${OUT_FILE}
/usr/bin/gpg --keyring /home/ec2-user/.gnupg/pubring.gpg --no-default-keyring --batch --passphrase ${PASSPHRASE} --decrypt ${IN_FILE} >/tmp/${OUT_FILE}
#echo $? >>/tmp/change.txt
case ${OUT_FILE} in
  *MA_AZ_Claims*)
     S3_BUCKET=s3://basehealth-data/cigna/inbound/claims/
     ;;
  *MA_AZ_Membership*)
     S3_BUCKET=s3://basehealth-data/cigna/inbound/membership/
     ;;
  *_AZ_Labs*)
     S3_BUCKET=s3://basehealth-data/cigna/inbound/labs/
     ;;
  *_AZ_RxClaims*)
     S3_BUCKET=s3://basehealth-data/cigna/inbound/rx/
     ;;
  *)
     echo "DEFAULT"
esac
echo ${S3_BUCKET}
aws s3 cp "/tmp/${OUT_FILE}" ${S3_BUCKET}
exit
