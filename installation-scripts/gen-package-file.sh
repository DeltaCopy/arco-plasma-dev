#!/usr/bin/env sh
set -o pipefail
echo "##################################################################"
echo "Merging personal package list with package.x86_64"
echo "This ignores duplicates, ignore empty lines"
echo "##################################################################"


desktop=$1
buildFolder=$2

packages="$buildFolder/archiso/packages.x86_64"
packages_personal="../archiso/packages-personal-repo.x86_64"
packages_tmp=()

case $desktop in
  "plasma")
    echo "plasma"
    wget -q https://raw.githubusercontent.com/arcolinuxb/arco-plasma/master/archiso/packages.x86_64 -O $packages
  ;;
  *)
  echo "desktop not recognized, or setup!"
  exit 1
  ;;
esac

echo "Packages file = $packages"
echo "Personal packages file = $packages_personal"

if test -s $packages && test -s $packages_personal; then

  # read in the package-personal-repo.x86_64 file store into memory
    while read pkg; do
      if [[ ! -z "$pkg" ]]; then
          grep -Fxq "$pkg" "$packages" || packages_tmp+=("$pkg")
      fi
    done<$packages_personal
else
  echo "Error: $packages/$packages_personal doesn't exist."
  exit 1
fi

echo "Personal packages to merge = ${#packages_tmp[@]}"

# check there are personal packages to add, then add this into packages.x86_64
if test ${#packages_tmp[@]} -gt 0; then
  printf "\n" >> $packages
  echo "# Personal Packages Start" >> $packages


  for pkg in  "${packages_tmp[@]}"; do
    echo "Adding $pkg into $packages"
    echo $pkg >> $packages
  done

  echo "# Personal Packages End" >> $packages
  if test -s $packages; then echo "Merged packages added into = $packages"; exit 0; fi
else
  echo "Files are identical"
fi
