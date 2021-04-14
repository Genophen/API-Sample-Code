DATE_TIME=`date +"%Y%m%d_%H%M%S"`
OUT1=YO11000__yo10001i.74350.${DATE_TIME}.txt
OUT2=YO11000__yo10002i.74350.${DATE_TIME}.txt
echo "This is the yo10001i file with no data " >${OUT1}
echo "This is the yo10002i file with no data " >${OUT2}
for FILE_NAME in ${OUT1} ${OUT2} 
do
	echo "gpg -e -u 'Cigna Data <prakash.menon+cigna_data@genalyte.com>' -r 'Prod CIGNA B2B knexp1 (CIGNA B2B eCommerce) <eCommerce@cigna.com>' -o ${FILE_NAME}.pgp ${FILE_NAME}"
	gpg -e -u 'Cigna Data <prakash.menon+cigna_data@genalyte.com>' -r 'Prod CIGNA B2B knexp1 (CIGNA B2B eCommerce) <eCommerce@cigna.com>' -o ${FILE_NAME}.pgp --yes  ${FILE_NAME}
done
