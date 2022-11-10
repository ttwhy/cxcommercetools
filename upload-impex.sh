#!/bin/bash
USER=admin
PWD=nimda
ADMIN=https://localhost:9002
FILE=myfile.impex
COOKIE=$(mktemp $TMPDIR/cx-commerce-upload-cookie.XXXXXX)

# fetch login CSRF Token
TOKEN=$(curl -b $COOKIE -c $COOKIE --request GET "$ADMIN/login.jsp" -k -s | awk -F 'name=\"_csrf\"' '/content/ {print $2}' | cut -d '"' -f2)

# Login the user
curl -H "X-CSRF-Token: $TOKEN" -b $COOKIE -c $COOKIE -o- -d j_username=$USER -d j_password=$PWD -d _csrf=$TOKEN "$ADMIN/j_spring_security_check" -k 

# get import CSRF Token
TOKEN2=$(curl -b $COOKIE -c $COOKIE --request GET "$ADMIN/console/impex/import" -s -k | awk -F 'name=\"_csrf\"' '/_csrf/ {print $2; exit}' | cut -d '"' -f2)
 
 echo Token2: $TOKEN2
 
 echo "=== Importing script '$FILE' ==="
 RES=`curl -H "Referer: $ADMIN/console/impex/import/" -f -c $COOKIE -b $COOKIE -o- -s -D ${COOKIE}.hdr -F encoding="UTF-8" -F maxThreads=1 -F legacyMode=true -F _legacyMode=on -F validationEnum=IMPORT_STRICT -F file="@$FILE;type=octet/stream;filename=$(basename $FILE)" -F enableCodeExecution=true -F _enableCodeExecution=on "$ADMIN/console/impex/import/upload?_csrf="$TOKEN2 -k`
 RES=`curl -H "Referer: $ADMIN/console/impex/import/" -f -c $COOKIE -b $COOKIE -o- -s -D ${COOKIE}.hdr -F encoding="UTF-8" -F maxThreads=1 -F legacyMode=true -F _legacyMode=on -F validationEnum=IMPORT_STRICT -F file="@$FILE;type=octet/stream;filename=$(basename $FILE)" -F enableCodeExecution=true -F _enableCodeExecution=on "$ADMIN/console/impex/import/upload?_csrf="$TOKEN2 -k`
 rm $COOKIE

