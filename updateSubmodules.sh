#!/bin/bash
function tryAdd () {
	git add .
	return $?
}


# Pull all submodules
echo "Checking if there are changes"
git submodule foreach git checkout master
git submodule foreach git pull

#Try add
ERROR=$(tryAdd)

if [ $ERROR -gt 0 ] ; then
	echo "There are not changes"
else
	echo "Trying to push submodules"
	git commit -m "Update submodules"
	git push origin master
fi

exit 0
