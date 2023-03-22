#!/bin/bash
#set -e
##################################################################################################################
# Author	:	Erik Dubois
# Website	:	https://www.erikdubois.be
# Website	:	https://www.arcolinux.info
# Website	:	https://www.arcolinux.com
# Website	:	https://www.arcolinuxd.com
# Website	:	https://www.arcolinuxb.com
# Website	:	https://www.arcolinuxiso.com
# Website	:	https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
echo
echo "################################################################## "
tput setaf 2
echo "Phase 1 : "
echo "- Setting General parameters"
tput sgr0
echo "################################################################## "
echo

	if ! type "wget" > /dev/null; then
		echo "wget not found, install it and retry the install"
		exit 1
	fi

	# if this is a vanilla arch install setup pacman.conf, and import key
	test -s /etc/pacman.d/arcolinux-mirrorlist ||
		cat << EOF > /etc/pacman.d/arcolinux-mirrorlist
		# Europe Netherlands Amsterdam
#Server = https://ant.seedhost.eu/arcolinux/$repo/$arch

# Gitlab United States
Server = https://gitlab.com/arcolinux/$repo/-/raw/main/$arch

# Sweden - accum.se
Server = https://mirror.accum.se/mirror/arcolinux.info/$repo/$arch

# Europe Belgium Brussels
Server = https://ftp.belnet.be/arcolinux/$repo/$arch

# Australia
Server = https://mirror.aarnet.edu.au/pub/arcolinux/$repo/$arch

# South Korea
Server = https://mirror.funami.tech/arcolinux/$repo/$arch

# Singapore
Server = https://mirror.jingk.ai/arcolinux/$repo/$arch

# United States San Francisco - no xlarge repo here
Server = https://arcolinux.github.io/$repo/$arch
EOF

	pacman-key --lsign-key 74F5DE85A506BF64

	#Let us set the desktop"
	#First letter of desktop is small letter

	desktop="plasma"
	dmDesktop="plasma"
	# Fetch desktop iso, or plasma packages_x86_64 file from GitHub
	#packages_x86_64="plasma"


	arcolinuxVersion='v23.04.03'

	isoLabel='arcolinuxb-'$desktop'-'$arcolinuxVersion'-x86_64.iso'

	# setting of the general parameters
	archisoRequiredVersion="archiso 70-1"
	buildFolder=$HOME"/arcolinuxb-build"
	outFolder=$HOME"/ArcoLinuxB-Out"
	archisoVersion=$(sudo pacman -Q archiso)

	# If you are ready to use your personal repo and personal packages
	# https://arcolinux.com/use-our-knowledge-and-create-your-own-icon-theme-combo-use-github-to-saveguard-your-work/
	# 1. set variable personalrepo to true in this file (default:false)
	# 2. change the file personal-repo to reflect your repo
	# 3. add your applications to the file packages-personal-repo.x86_64

	personalrepo=true

	echo "################################################################## "
	echo "Building the desktop                   : "$desktop
	echo "Building version                       : "$arcolinuxVersion
	echo "Iso label                              : "$isoLabel
	echo "Do you have the right archiso version? : "$archisoVersion
	echo "What is the required archiso version?  : "$archisoRequiredVersion
	echo "Build folder                           : "$buildFolder
	echo "Out folder                             : "$outFolder
	echo "################################################################## "

	if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
		tput setaf 2
		echo "##################################################################"
		echo "Archiso has the correct version. Continuing ..."
		echo "##################################################################"
		tput sgr0
	else
	tput setaf 1
	echo "###################################################################################################"
	echo "You need to install the correct version of Archiso"
	echo "Use 'sudo downgrade archiso' to do that"
	echo "or update your system"
	echo "###################################################################################################"
	tput sgr0
	fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 2 :"
echo "- Checking if archiso is installed"
echo "- Saving current archiso version to readme"
echo "- Making mkarchiso verbose"
tput sgr0
echo "################################################################## "
echo

	package="archiso"

	#----------------------------------------------------------------------------------

	#checking if application is already installed or else install with aur helpers
	if pacman -Qi $package &> /dev/null; then

			echo "Archiso is already installed"

	else

		#checking which helper is installed
		if pacman -Qi yay &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with yay"
			echo "################################################################"
			yay -S --noconfirm $package

		elif pacman -Qi trizen &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with trizen"
			echo "################################################################"
			trizen -S --noconfirm --needed --noedit $package

		fi

		# Just checking if installation was successful
		if pacman -Qi $package &> /dev/null; then

			echo "################################################################"
			echo "#########  "$package" has been installed"
			echo "################################################################"

		else

			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo "!!!!!!!!!  "$package" has NOT been installed"
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			exit 1
		fi

	fi

	echo
	echo "Saving current archiso version to readme"
	sudo sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" ../archiso.readme
	echo
	echo "Making mkarchiso verbose"
	sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 3 :"
echo "- Deleting the build folder if one exists"
echo "- Git clone the latest ArcoLinux-iso from github"
echo "- Add our own personal repo + add your packages to packages-personal-repo.x86_64"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo rm -rf $buildFolder
	echo
	echo "Git clone the latest ArcoLinux-iso from github"
	echo
	test -d ../work && rm -rf ../work
	git clone https://github.com/arcolinux/arcolinuxl-iso ../work
	echo

	if [ $personalrepo == true ]; then
		if test -s personal-repo && [[ ! -z $(grep '[^[:space:]]' personal-repo) ]]; then
			echo "Adding our own repo to /etc/pacman.conf"
			printf "\n" | sudo tee -a ../work/archiso/pacman.conf
			printf "\n" | sudo tee -a ../work/archiso/airootfs/etc/pacman.conf
			cat personal-repo | sudo tee -a ../work/archiso/pacman.conf
			cat personal-repo | sudo tee -a ../work/archiso/airootfs/etc/pacman.conf
		fi
	fi

	echo
	echo "Adding the content of the /personal folder"
	echo
	cp -rf ../personal/ ../work/archiso/airootfs/

	if test -f ../work/archiso/airootfs/personal/.gitkeep ; then
		echo
		rm ../work/archiso/airootfs/personal/.gitkeep
		echo ".gitkeep is now removed"
		echo
    fi
	echo "Copying the Archiso folder to build work"
	echo
	mkdir $buildFolder
	cp -r ../work/archiso $buildFolder/archiso
	rm -rf ../work

echo
echo "################################################################## "
tput setaf 2
echo "Phase 4 :"
echo "- Deleting any files in /etc/skel"
echo "- Getting the last version of bashrc in /etc/skel"
echo "- Removing the old packages.x86_64 file from build folder"
echo "- Copying the new packages.x86_64 file to the build folder"
echo "- Adding packages from your personal repository - packages-personal-repo.x86_64"
echo "- Changing group for polkit folder"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting any files in /etc/skel"
	rm -rf $buildFolder/archiso/airootfs/etc/skel/.* 2> /dev/null
	echo

	echo "Getting the last version of bashrc in /etc/skel"
	echo
	wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O $buildFolder/archiso/airootfs/etc/skel/.bashrc

	echo "Removing the old packages.x86_64 file from build folder"
	rm $buildFolder/archiso/packages.x86_64
	rm $buildFolder/archiso/packages-personal-repo.x86_64
	echo
	#echo "Copying the new packages.x86_64 file to the build folder"
	#cp -f ../archiso/packages.x86_64 $buildFolder/archiso/packages.x86_64
	echo

	if [ $personalrepo == true ]; then

		if test -s $buildFolder/archiso/packages.x86_64; then
			echo "Adding packages from your personal repository - packages-personal-repo.x86_64"
			printf "\n" | sudo tee -a $buildFolder/archiso/packages.x86_64
			#cat ../archiso/packages-personal-repo.x86_64 | sudo tee -a $buildFolder/archiso/packages.x86_64
		fi
		if sh gen-package-file.sh "$desktop" "$buildFolder"; then
			echo "Package list merged"
		else
			echo "Package list merge failed"
			exit 1
		fi
	fi

	echo
	echo "Changing group for polkit folder"
	sudo chgrp polkitd $buildFolder/archiso/airootfs/etc/polkit-1/rules.d
	#is not working so fixing this during calamares installation

echo
echo "################################################################## "
tput setaf 2
echo "Phase 5 : "
echo "- Changing all references"
echo "- Adding time to /etc/dev-rel"
tput sgr0
echo "################################################################## "
echo

	#Setting variables

	#profiledef.sh
	oldname1='iso_name="arcolinuxl'
	newname1='iso_name="arcolinuxb-'$desktop

	oldname2='iso_label="arcolinuxl'
	newname2='iso_label="arcolinuxb-'$desktop

	oldname3='ArcoLinuxL'
	newname3='ArcoLinuxB-'$desktop

	#hostname
	oldname4='ArcoLinuxL'
	newname4='ArcoLinuxB-'$desktop

	#sddm.conf user-session
	oldname5='Session=xfce'
	newname5='Session='$dmDesktop

	echo "Changing all references"
	echo
	sed -i 's/'$oldname1'/'$newname1'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname2'/'$newname2'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname3'/'$newname3'/g' $buildFolder/archiso/airootfs/etc/dev-rel
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/airootfs/etc/hostname
	sed -i 's/'$oldname5'/'$newname5'/g' $buildFolder/archiso/airootfs/etc/sddm.conf.d/kde_settings.conf
	#bios
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/syslinux/archiso_sys-linux.cfg
	#uefi
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/efiboot/loader/entries/1-archiso-x86_64-linux.conf
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/efiboot/loader/entries/2-archiso-x86_64-linux-no-nouveau.conf
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/efiboot/loader/entries/3-nvidianouveau.conf
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/efiboot/loader/entries/4-nvidianonouveau.conf
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/efiboot/loader/entries/5-nomodeset.conf

	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/grub/grub.cfg

	echo "Adding time to /etc/dev-rel"
	date_build=$(date -d now)
	echo "Iso build on : "$date_build
	sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/archiso/airootfs/etc/dev-rel


echo
echo "###########################################################"
tput setaf 2
echo "Phase 6 :"
echo "- Cleaning the cache from /var/cache/pacman/pkg/"
tput sgr0
echo "###########################################################"
echo

	echo "Cleaning the cache from /var/cache/pacman/pkg/"
	yes | sudo pacman -Scc


echo
echo "################################################################## "
tput setaf 2
echo "Phase 7 :"
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "################################################################## "
echo

	[ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/



echo
echo "###################################################################"
tput setaf 2
echo "Phase 8 :"
echo "- Creating checksums"
echo "- Copying pgklist"
tput sgr0
echo "###################################################################"
echo



	echo "Creating checksums for : "$isoLabel
	echo "##################################################################"
	echo
	echo "Building sha1sum"
	echo "########################"
	sha1sum "$outFolder/$isoLabel" | tee "$outFolder/$isoLabel.sha1"
	echo "Building sha256sum"
	echo "########################"
	sha256sum "$outFolder/$isoLabel" | tee "$outFolder/$isoLabel.sha256"
	echo "Building md5sum"
	echo "########################"
	md5sum "$outFolder/$isoLabel" | tee "$outFolder/$isoLabel.md5"
	echo
	echo "Moving pkglist.x86_64.txt"
	echo "########################"
	cp $buildFolder/iso/arch/pkglist.x86_64.txt  $outFolder/$isoLabel".pkglist.txt"

echo
echo "##################################################################"
tput setaf 2
echo "Phase 9 :"
echo "- Making sure we start with a clean slate next time"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	#[ -d $buildFolder ] && sudo rm -rf $buildFolder

echo
echo "##################################################################"
tput setaf 2
echo "DONE"
echo "- Check your out folder :"$outFolder
tput sgr0
echo "################################################################## "
echo
