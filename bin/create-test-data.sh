#!/bin/bash

assignPermission() {
    sf org assign permset \
    --name Create_reports_and_dashboards \
    --name Arbeidsgiver_WarningWrite \
    --name Arbeidsgiver_Create_and_share_reportfolders \
    --name Arbeidsgiver_Kampanje \
    --name Arbeidsgiver_NavApp \
    --name Arbeidsgiver_NavTask \
    --name Arbeidsgiver_Sykefravaer \
    --name Arbeidsgiver_arenaActivity \
    --name Arbeidsgiver_base \
    --name Arbeidsgiver_contract \
    --name Arbeidsgiver_opportunity \
    --name Arbeidsgiver_temporaryLayoffs \
    --name Arbeidsgiver_IA \
    --name ArbeidsgiverStillinger \
    --name Admin_Base \
    --name CRM_LoginFlow \
    --name TAG_Arbeidsgiver_Veillederapp \
    --name Arbeidsgiver_Beta_app \
    --name Arbeidsgiver_Kandidatutfall \
    || { error $? '"sf org assign permset" command failed.'; }
}

insertingTestData() {
    # Creating temporary folder for test data files.
    echo "Moving test data to temp folder..."
    mkdir -p dummy-data/temp
    cp -r dummy-data/tag dummy-data/temp
    echo ""

    # Getting the Record Types from the new scratch org.
    echo "Getting Record Types..."
    sf data query --query "SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive=true ORDER BY SObjectType, DeveloperName" --result-format json > dummy-data/temp/RecordTypes.json
    echo ""

    # Prepering Tag test data by replacing RecordType placeholders with correct Ids.
    echo "Prepering Tag test data..."
    echo "Prepering Account test data..."
    for p in $(jq '.result.records[] | select(.SobjectType=="Account") | .DeveloperName' dummy-data/temp/RecordTypes.json);
    do
        minTest=$(sed -e 's/^"//' -e 's/"$//' <<<"$p");
        replace="\$R{RecordType.Account.$(sed -e 's/^"//' -e 's/"$//' <<<"$p")}"
        replacewith=$(sed -e 's/^"//' -e 's/"$//' <<<"$(jq '.result.records[] | select(.SobjectType=="Account" and .DeveloperName=="'$minTest'") | .Id' dummy-data/temp/RecordTypes.json)");
        sed -i "" "s/$replace/$replacewith/g" "dummy-data/temp/tag/Accounts-B.json"
    done

    for p in $(jq '.result.records[] | select(.SobjectType=="Account") | .DeveloperName' dummy-data/temp/RecordTypes.json);
    do
        minTest=$(sed -e 's/^"//' -e 's/"$//' <<<"$p");
        replace="\$R{RecordType.Account.$(sed -e 's/^"//' -e 's/"$//' <<<"$p")}"
        replacewith=$(sed -e 's/^"//' -e 's/"$//' <<<"$(jq '.result.records[] | select(.SobjectType=="Account" and .DeveloperName=="'$minTest'") | .Id' dummy-data/temp/RecordTypes.json)");
        sed -i "" "s/$replace/$replacewith/g" "dummy-data/temp/tag/Accounts-J.json"
    done

    for p in $(jq '.result.records[] | select(.SobjectType=="Account") | .DeveloperName' dummy-data/temp/RecordTypes.json);
    do
        minTest=$(sed -e 's/^"//' -e 's/"$//' <<<"$p");
        replace="\$R{RecordType.Account.$(sed -e 's/^"//' -e 's/"$//' <<<"$p")}"
        replacewith=$(sed -e 's/^"//' -e 's/"$//' <<<"$(jq '.result.records[] | select(.SobjectType=="Account" and .DeveloperName=="'$minTest'") | .Id' dummy-data/temp/RecordTypes.json)");
        sed -i "" "s/$replace/$replacewith/g" "dummy-data/temp/tag/Accounts-O.json"
    done
    echo ""

    echo "Tag test data prepared..."
    echo ""

    # Inserting the prepared test data
    echo "Inserting test data..."
    sf data import tree --plan  dummy-data/temp/tag/plan.json || { error $? '"sf data import tree" command failed.'; }
    echo ""

    echo "Removing temporary files..."
    rm -rf dummy-data/temp
    echo ""
}

assignPermission

insertingTestData