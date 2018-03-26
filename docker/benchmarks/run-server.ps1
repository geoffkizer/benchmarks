foreach ($e in @("SERVER_IP","HARDWARE","HARDWARE_VERSION"))
{
    if (-Not (Test-Path 'env:$e')) 
    { 
        echo "$e is not defined"
        exit
    }
}

docker run --name benchmarks-server `
  -p 5001:5001 -p 5000:5000 -p 8080:8080 `
  benchmarks powershell `
  "dotnet published/BenchmarksServer.dll -n $env:SERVER_IP --hardware $env:HARDWARE --hardware-version $env:HARDWARE_VERSION"
