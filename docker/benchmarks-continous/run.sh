#!/usr/bin/env bash

set -x

while [ $# -ne 0 ]
do
    name="$1"
    case "$name" in
        --sql)
            shift
            sql="/p:BENCHMARK_SQL=\"$1\""
            ;;
        -s|--server)
            shift
            server="$1"
            ;;
        -c|--client)
            shift
            client="$1"
            ;;
        *)
            say_err "Unknown argument \`$name\`"
            exit 1
            ;;
    esac

    shift
done

if [ -z "$server" ]
then
    echo "--server needs to be set"
    exit 1
fi

if [ -z "$client" ]
then
    echo "--client needs to be set"
    exit 1
fi

docker run \
    -d \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    --mount type=bind,source=/mnt,target=/logs \
    --name benchmarks-scenarios \
    --network host \
    --restart always \
    benchmarks-scenarios \
    bash -c \
    "dotnet msbuild ./build/repo.proj \
    /p:BENCHMARK_SERVER=\"$server\" \
    /p:BENCHMARK_CLIENT=\"$client\"  \
    /p:DriverOutputPath=\"/benchmarks/src/BenchmarksDriver/published/\" \
    $sql \
    | tee /logs/scenarios-\$(date '+%Y-%m-%dT%H-%M').log "
    