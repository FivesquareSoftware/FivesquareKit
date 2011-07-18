#! /bin/sh

# build-universal.sh
# Created by John Clayton on 5/26/2010.

target="FivesquareKit"
product="libFivesquareKit.a"
xcodebuild=/Developer/usr/bin/xcodebuild


# clean and build the project for each architecture and configuration


configurations=( Debug Release )
for configuration in "${configurations[@]}"
do
	products=();

	output_dir="build/${configuration}-universal"
    product_output_path="$output_dir/$product"

	# Wipe out previous stuff
	rm -Rf $output_dir
	mkdir $output_dir
	
	sdks=( iphoneos iphonesimulator )
	for sdk in "${sdks[@]}"
	do
		$xcodebuild -target $target -sdk $sdk -configuration $configuration -parallelizeTargets clean build
		if [ $? != 0 ]
		then
			echo "\n\n\n!!!!!!!!!!!!!! Build failed for $configuration $sdk !!!!!!!!!!!!!!!!!!"
			say "Dood, $target is broke for $configuration $sdk\!  Fix it\!"
			exit 1
		fi
		products=( "${products[@]}" "build/${configuration}-${sdk}/${product}" )
	done
	
	# package the individual libraries as a universal for this configuration

	lipo ${products[@]} -create -output ${product_output_path}
	
done






