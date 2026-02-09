xcrun --show-sdk-path

export SDKROOT=$(xcrun --show-sdk-path)
export CPATH=$SDKROOT/usr/include
export CPLUS_INCLUDE_PATH=$SDKROOT/usr/include/c++/v1

make clean
make sim