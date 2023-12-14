# oci_listpviews



```
#!/bin/bash
#run_pviewlist.sh

rm -f missingviewslist_$region.log

rm -f pviewlist.sh
wget https://raw.githubusercontent.com/BaptisS/oci_listpviews/main/pviewlist.sh
chmod +x pviewlist.sh

rm -f complistid.file

complist=$(oci iam compartment list --all --compartment-id-in-subtree true)
echo $complist | jq .data | jq -r '.[] | ."id"' > complistid.file

## First region

export region=''
export resolverid01=''
#export resolverid02=''
#export resolverid03=''

#./pviewlist.sh $region $resolverid01 $resolverid02 $resolverid03
./pviewlist.sh $region $resolverid01 

## Second Region

export region=''
export resolverid01=''

./pviewlist.sh $region $resolverid01

cat missingviewslist_$region.log

```
