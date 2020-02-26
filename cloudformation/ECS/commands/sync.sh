cd "${BASH_SOURCE%/*}" || exit
cd ..
COMMAND=$(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' config.yml)
eval $COMMAND
aws s3 sync . "s3://$TemplatesBucketName/$Prefix" --exclude "*" --include "*.yml" --include "*.zip"