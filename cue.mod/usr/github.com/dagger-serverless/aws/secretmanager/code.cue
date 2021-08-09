package secretmanager

#command: #"""
    # Loop on all files, including hidden files
    shopt -s dotglob
    echo "{}" > /tmp/output.json
    for FILE in /tmp/secrets/*; do
        BOOL=0 # Boolean

        aws secretsmanager describe-secret --secret-id "${FILE##*/}" 2>/dev/null > /dev/null
        status=$?
        # If secret not found
        if [[ ! "${status}" -eq 0 ]]; then
            (\
                RES=$(aws secretsmanager create-secret --name "${FILE##*/}" --secret-string "$(cat $FILE)" | jq -r .ARN) \
                && cat <<< $(cat /tmp/output.json | jq ".|.\"${FILE##*/}\"=\"'{{resolve:secretsmanager:$RES}}'\"") > /tmp/output.json \
            ) || (echo "Error while creating secret ${FILE##*/}" >&2 && exit 1)
            BOOL=1
        else
            TMP="$(aws secretsmanager get-secret-value --secret-id "${FILE##*/}" | jq -r .SecretString)"
            # If changed
            if [ "$TMP" != "$(cat $FILE)" ]; then
                (\
                    RES=$(aws secretsmanager update-secret --secret-id "${FILE##*/}" --secret-string "$(cat $FILE)" | jq -r .ARN) \
                    && cat <<< $(cat /tmp/output.json | jq ".|.\"${FILE##*/}\"=\"'{{resolve:secretsmanager:$RES}}'\"") > /tmp/output.json \
                ) || (echo "Error while updating secret ${FILE##*/}" >&2 && exit 1)
                BOOL=1
            fi
        fi

        if [ $BOOL -eq 0 ]; then
            (\
                RES=$(aws secretsmanager describe-secret --secret-id "${FILE##*/}" | jq -r .ARN) \
                && cat <<< $(cat /tmp/output.json | jq ".|.\"${FILE##*/}\"=\"'{{resolve:secretsmanager:$RES}}'\"") > /tmp/output.json \
            ) || (echo "Error while retrieving secret ${FILE##*/}" >&2 && exit 1)
        fi
    done
"""#