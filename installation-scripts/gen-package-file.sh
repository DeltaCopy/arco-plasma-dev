#!/usr/bin/env sh
set -o pipefail
echo "##################################################################"
echo "Merging personal package list with package.x86_64"
echo "This removes duplicates, ignore comments and empty lines"
echo "##################################################################"

packages="../archiso/packages.x86_64"
packages_personal="../archiso/packages-personal-repo.x86_64"
packages_tmp=()

if test -s $packages && test -s $packages_personal; then
  # take a backup of the packages.x86_64 file
  cp $packages $packages.bak

  # read in the package-personal-repo.x86_64 file store into memory
    while read pkg; do
    if [[ "$pkg" != \#* ]] && [[ ! -z "$pkg" ]]; then

      grep -Fxq "$pkg" "$packages" || packages_tmp+=($pkg)
    fi
  done<$packages_personal
fi

echo "Personal packages to merge = ${#packages_tmp[@]}"

# check there are personal packages to add, then add this into packages.x86_64
if test ${#packages_tmp[@]} -gt 0; then

  echo "############################################################################" >> $packages
  echo "#             START OF PERSONAL PACKAGES                                    " >> $packages
  echo "############################################################################" >> $packages

  for pkg in  ${packages_tmp[@]}; do
    echo $pkg >> $packages
  done

  echo "############################################################################" >> $packages
  echo "#             END OF PERSONAL PACKAGES                                      " >> $packages
  echo "############################################################################" >> $packages

  if test -s $packages; then echo "Merged packages added into = $packages"; exit 0; fi

fi
