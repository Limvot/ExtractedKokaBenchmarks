#!/usr/bin/env bash
set -e

if [[ ! -d "build" ]]
then
	mkdir build
	pushd build
	nix develop -i -c bash -c 'cmake .. -DCMAKE_BUILD_TYPE=Release && cmake --build .'
	popd
fi

rm -rf  ./build/CMakeFiles || true
nix develop -i -c bash -c 'ulimit -s unlimited && find build -type f -executable -print | xargs hyperfine --warmup 2 --export-markdown table.md'
