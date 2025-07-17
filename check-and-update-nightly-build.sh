#!/bin/bash

yaml_file="snapcraft.yaml"

current_build_checksum="$(yq '.parts.0ad-unix-build.source-checksum' "${yaml_file}")"
current_data_checksum="$(yq '.parts.0ad-unix-data.source-checksum' "${yaml_file}")"

base_url="https://jenkins.wildfiregames.com/job/0ad-bundles/lastSuccessfulBuild"
checksums_url="${base_url}/pipeline-console/log?nodeId=67"
checksum_algorithm="sha1"
checksums=$(curl -s "${checksums_url}" | tail -n +2)
newest_build_checksum="${checksum_algorithm}/$(echo "${checksums}" | grep "unix-build.tar.xz" | cut -d' ' -f1)"
newest_data_checksum="${checksum_algorithm}/$(echo "${checksums}" | grep "unix-data.tar.xz" | cut -d' ' -f1)"

if [ -z "${newest_build_checksum}" ] || [ -z "${newest_data_checksum}" ]; then
  echo "Failed to retrieve the checksums for the last successful nightly build, bailing out."
  exit 0
fi

if [ "${newest_build_checksum}" = "${current_build_checksum}" ] && \
    [ "${newest_data_checksum}" = "${current_data_checksum}" ]; then
  echo "Already packaging the latest nightly build, nothing to do."
  exit 0
fi

newest_build_source="${base_url}/artifact/$(echo "${checksums}" | grep "unix-build.tar.xz" | cut -d' ' -f3)"
newest_data_source="${base_url}/artifact/$(echo "${checksums}" | grep "unix-data.tar.xz" | cut -d' ' -f3)"

export newest_build_source
export newest_build_checksum
export newest_data_source
export newest_data_checksum

new_file="${yaml_file}.new"
cp "${yaml_file}" "${new_file}"

yq -i '.parts.0ad-unix-build.source = env(newest_build_source)' "${new_file}"
yq -i '.parts.0ad-unix-build.source-checksum = env(newest_build_checksum)' "${new_file}"
yq -i '.parts.0ad-unix-data.source = env(newest_data_source)' "${new_file}"
yq -i '.parts.0ad-unix-data.source-checksum = env(newest_data_checksum)' "${new_file}"

patch_file="${yaml_file}.patch"
diff --ignore-space-change --ignore-blank-lines "${yaml_file}" "${new_file}" > "${patch_file}"
patch "${yaml_file}" "${patch_file}"
rm "${new_file}" "${patch_file}"

