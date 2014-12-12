#!/bin/bash

download_and_install()
{
    cd Frameworks
    # Ratatosk
    git clone https://github.com/wireload/Ratatosk.git Ratatosk
    mkdir Source
    cd Source
    ln -s ../Ratatosk .
    cd ../Debug
    ln -s ../Ratatosk .
}

build()
{
    OBJJ_INCLUDE_PATHS="Frameworks" CONFIG="Release" jake build
}

dbuild()
{
    OBJJ_INCLUDE_PATHS="Frameworks:Frameworks/Debug" jake build
}

test()
{
    OBJJ_INCLUDE_PATHS="Frameworks:Frameworks/Debug" ojtest Tests/**/*.j
}

build_test_and_run()
{
    test
    build
    cd Build/Debug/RodanNext
    python ../../../server.py
}

run()
{
    python server.py
}

case "$1" in
    "install" ) download_and_install;;
    "test" ) test;;
    "build" ) build;;
    "dbuild" ) dbuild;;
    "br" ) build_test_and_run;;
    "run" ) run;;
    * )
        echo "Build options:"
        echo "    install               - Downloads the external framework dependencies and installs them"
        echo "    test                  - Runs the Unit tests"
        echo "    build                 - Builds the Release framework for deployment"
        echo "    dbuild                - Builds the Debug framework"
        echo "    br                    - Run the unit tests, build and then run a Python webserver on the built instance"
        echo "    run                   - Run a Python web server on the un-build application"
    ;;
esac