#!/bin/bash -e

release_artifacts() {
        local deb_linux_assets='Fedora-34 Ubuntu-18.04 Ubuntu-20.04 Ubuntu-22.04'
        cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}"
        for i in $deb_linux_assets; do
                cd "Linux-${i}"
		if [ "${i}" == "Fedora-34" ]; then 
			find . -name '*.rpm' -exec mv {} ../ ";"
		fi
                find . -name '*.deb' -exec mv {} ../ ";"
                cd ../
                rm -r "Linux-${i}"
        done

	local pkg_assets='macOS-11 macOS-12'
        cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}"
        for i in $pkg_assets; do
                cd "${i}"
		
		# change artifact name
		old_name=$(find . -name '*.pkg' | cut -b 3-26)
		name=$(echo "${old_name}" | cut -b 1-20)
		new_name="${name}-${i}.pkg"
		mv ./"${old_name}" ./"${new_name}"

                find . -name '*.pkg' -exec mv {} ../ ";"
		find . -name '*.tar.gz' -exec mv {} ../ ";"
                cd ../
                rm -r "${i}"
        done

        local zip_assets='2019 2022'
        cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}"
        for i in $zip_assets; do
		zip -r "Windows-VS-${i}-x64".zip "Windows-VS-${i}-x64"
		rm -r "Windows-VS-${i}-x64"
        done

        local deb_arm_assets='arm32v7 arm64v8 ppc64le x390x'
        cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}"
        for i in $deb_arm_assets; do
                cd "Ubuntu-${i}"
                find . -name '*.deb' -exec mv {} ../ ";"
                cd ../
                rm -r "Ubuntu-${i}"
        done

}

swdownloads_artifacts() {
        local linux_dist='Fedora-34 Ubuntu-18.04 Ubuntu-20.04 Ubuntu-22.04'
        for distribution in $linux_dist; do
		cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}/Linux-${distribution}"
		if [ "${distribution}" == "Fedora-34" ]; then
                        find . -name '*.rpm' -exec mv {} ../"${distribution}_latest_master_libiio.rpm" ";"
                fi
                find . -name '*.tar.gz' -exec mv {} ../"${distribution}_latest_master_libiio.tar.gz" ";"
                find . -name '*.deb' -exec mv {} ../"${distribution}_latest_master_libiio.deb" ";"
                rm -r ../Linux-"${distribution}"
        done

	local macOS_dist='macOS-11 macOS-12'
	for distribution in $macOS_dist; do
                cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}/${distribution}"
                find . -name '*.pkg' -exec mv {} ../"${distribution}_latest_master_libiio.pkg" ";"
                find . -name '*.tar.gz' -exec mv {} ../"${distribution}_latest_master_libiio.tar.gz" ";"
                rm -r ../"${distribution}"
        done

	local windows_dist='2019 2022'
        for distribution in $windows_dist; do
		cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}"
                zip -r "Windows-VS-${distribution}-x64-latest_master_libiio".zip "Windows-VS-${distribution}-x64"
                rm -r "Windows-VS-${distribution}-x64"
        done

	local arm_dist='arm32v7 arm64v8 ppc64le x390x'
        for distribution in $arm_dist; do
                cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}/Ubuntu-${distribution}"
                find . -name '*.tar.gz' -exec mv {} ../"Ubuntu-${distribution}_latest_master_libiio.tar.gz" ";"
                find . -name '*.deb' -exec mv {} ../"Ubuntu-${distribution}_latest_master_libiio.deb" ";"
                rm -r ../Ubuntu-"${distribution}"
        done

	cd "${BUILD_ARTIFACTSTAGINGDIRECTORY}/Libiio-Setup-Exe"
	mv libiio-setup.exe ../libiio-setup.exe
	rm -r ../Libiio-Setup-Exe
}

check_artifacts() {
	cd build
	while IFS= read -r line; do
		if [ -z "${line}" ]; then continue
		fi
		test -f ./artifacts/"${line}" && echo "${line} exist." || echo "${line} does not exist."
	done < "artifact_manifest.txt"
}

"${1}"_artifacts
