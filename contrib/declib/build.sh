#!/bin/bash

# Where to find the sources
ZSTD_SRC_ROOT="../../lib"

# Temporary compiled binary
OUT_FILE="tempbin"

# Optional temporary compiled WebAssembly
OUT_WASM="temp.wasm"

# Amalgamate the sources
./combine.sh -r "$ZSTD_SRC_ROOT" -r "$ZSTD_SRC_ROOT/common" -r "$ZSTD_SRC_ROOT/decompress" -o zstddeclib.c zstddeclib-in.c
# Did combining work?
if [ $? -ne 0 ]; then
  echo "Combine script: FAILED"
  exit 1
fi
echo "Combine script: PASSED"

# Compile the generated output
cc -Os -g0 -o $OUT_FILE examples/simple.c
# Did compilation work?
if [ $? -ne 0 ]; then
  echo "Compiling simple.c: FAILED"
  exit 1
fi
echo "Compiling simple.c: PASSED"

# Run then delete the compiled output
./$OUT_FILE
retVal=$?
rm -f $OUT_FILE
# Did the test work?
if [ $retVal -ne 0 ]; then
  echo "Running simple.c: FAILED"
  exit 1
fi
echo "Running simple.c: PASSED"

# Is Emscripten available?
which emcc > /dev/null
if [ $? -ne 0 ]; then
  echo "(Skipping Emscripten test)"
fi
# Compile the Emscripten example
CC_FLAGS="-Wall -Wextra -Os -g0 -flto --llvm-lto 3 -lGL -DNDEBUG=1"
emcc $CC_FLAGS -s WASM=1 -o $OUT_WASM examples/emscripten.c
# Did compilation work?
if [ $? -ne 0 ]; then
  echo "Compiling emscripten.c: FAILED"
  exit 1
fi
echo "Compiling emscripten.c: PASSED"
rm -f $OUT_WASM

exit 0
