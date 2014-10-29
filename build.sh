#!/bin/bash

download()
{
    cd Frameworks
    # Ratatosk
    git clone https://github.com/wireload/Ratatosk.git Ratatosk
}

build()
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
    python -m SimpleHTTPServer
}

run()
{
    python -m SimpleHTTPServer
}

case "$1" in
    "download" ) download;;
    "test" ) test;;
    "build" ) build;;
    "br" ) build_test_and_run;;
    "run" ) run;;
    * )
        echo "Build options:"
        echo "    download              - Downloads the external framework dependencies"
        echo "    test                  - Runs the Unit tests"
        echo "    build                 - Builds the framework for deployment"
        echo "    br                    - Run the unit tests, build and then run a Python webserver on the built instance"
        echo "    run                   - Run a Python web server on the un-build application"
    ;;
esac