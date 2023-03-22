#!/usr/bin/env sh
set -o pipefail
echo "##################################################################"
echo "Merging personal package list with package.x86_64"
echo "This ignores duplicates, ignore empty lines"
echo "##################################################################"


desktop=$1
buildFolder=$2

if [ -z "$desktop" ] || [ -z $buildFolder ]; then
  echo "Desktop or build folder name cannot be empty"
  exit 1
fi

packages="$buildFolder/archiso/packages.x86_64"
packages_personal="../archiso/packages-personal-repo.x86_64"
packages_tmp=()
github_arcob_url="https://raw.githubusercontent.com/arcolinuxb/arco-$desktop/master/archiso/packages.x86_64"

# a guard in case we don't get a valid desktop name
case $desktop in
  "plasma")
    echo "Generating packages list for ArcoLinuxB-Plasma"

    wget -q "$github_arcob_url" -O $packages
  ;;
  *)
  echo "Desktop not recognized, or setup!"
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
  echo "Error: $packages OR $packages_personal doesn't exist."
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
