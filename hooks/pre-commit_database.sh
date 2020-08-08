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

cargo_wrap_file="server/database/scripts/cargo_wrap"

# Format files
# Build & Run Tests
verify_call "$cargo_wrap_file test"

# Run Clippy
verify_call "$cargo_wrap_file clippy"
