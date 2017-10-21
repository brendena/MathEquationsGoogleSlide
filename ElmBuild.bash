#!/bin/bash
echo "BuildScript"

elm-make SelectInput.elm --output=SelectInput.js

mv SelectInput.js SelectInput.html

sed -i '1s/^/<script>/' SelectInput.html
echo "</script>" >> SelectInput.html

git add --all