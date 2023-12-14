#!/bin/bash
#pviewlist.sh
export region=$1
export resolverid01=$2
export resolverid02=$3
export resolverid03=$4


rm -f viewlistfull-$region.log
rm -f viewidlistfull-$region.log
rm -f updatedviews_u.log

echo Looking for DNS views across compartments in $region
complistcur=$(cat complistid.file)
for compocid in $complistcur; do echo Enumerating DNS Private Views in $region $compocid && oci dns view list --compartment-id $compocid --region $region --all --scope PRIVATE --query 'data[?("is-protected")]' >> viewlistfull-$region.log ; done
cat viewlistfull-$region.log | jq -r '.[] | ."id"' > viewidlistfull-$region.log

viewnumber=$(cat viewidlistfull-$region.log | wc -l)

rm -f viewlistfull-$region.log

rm -f updatedviews.log
oci dns resolver get --region $region --resolver-id $resolverid01 | jq -r '.data."attached-views"[] | ."view-id"' >> updatedviews.log
oci dns resolver get --region $region --resolver-id $resolverid02 | jq -r '.data."attached-views"[] | ."view-id"' >> updatedviews.log
oci dns resolver get --region $region --resolver-id $resolverid03 | jq -r '.data."attached-views"[] | ."view-id"' >> updatedviews.log

cat updatedviews.log | sort | /usr/bin/uniq > updatedviews_u.log
rm -f updatedviews.log
assocviewnumber=$(cat updatedviews_u.log | wc -l)

rm -f missingviews_$region.log
echo ##################################################################
echo Missing Private Views in $region >> missingviews_$region.log
echo ##################################################################

echo Protected Private DNS Views across all compartments : $viewnumber
echo Associated Private DNS Views : $assocviewnumber

export missingviews=$(grep -xvFf viewidlistfull-$region.log updatedviews_u.log; grep -xvFf updatedviews_u.log viewidlistfull-$region.log)
for view in $missingviews
    do
        oci dns view get --view-id $view --region $region > $view.logs
        export protected=$(cat $view.logs | jq -r '.data | ."is-protected"')
        if $protected = true
        then
            export viewname=$(cat $view.logs | jq -r '.data | ."display-name"')
            export compocid=$(cat $view.logs | jq -r '.data | ."compartment-id"')
            oci iam compartment get --compartment-id $compocid > $view.comp
            export compname=$(cat $view.comp | jq -r '.data | ."name"')
            echo $viewname - $compname >> missingviews_$region.log
            rm -f $view.*
        else
            rm -f $view.*
        fi
        echo ##################################################################
        cat missingviews_$region.log >> missingviewslist_$region.log
    done
    

