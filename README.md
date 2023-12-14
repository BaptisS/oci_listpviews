# oci_listpviews



```
#!/bin/bash
#run_pviewlist.sh

rm -f complistid.file
complist=$(oci iam compartment list --all --compartment-id-in-subtree true)
echo $complist | jq .data | jq -r '.[] | ."id"' > complistid.file

export region=''
export resolverid01=''
#export resolverid02=''
#export resolverid03=''

#./pviewlist.sh $region $resolverid01 $resolverid02 $resolverid03
./pviewlist.sh $region $resolverid01 

export region=''
export resolverid01=''

./pviewlist.sh $region $resolverid01

cat missingviews_*.log
missingviewslist_$region.log
```
