# TODO: Figure out how to capture output and print it. 
function verify_call {
  eval $1
  status=$?

  if [ $status -ne 0 ];
  then
    echo "Ran \"$1\":"
    echo "Status code is: $status"
    exit $status
  fi
}

manifest_file="server/database/Cargo.toml"

# Format files
# Build
verify_call "cargo build --manifest-path $manifest_file"

# Run Tests
verify_call "cargo test --manifest-path $manifest_file"

# Run Clippy
verify_call "cargo clippy --manifest-path $manifest_file"

