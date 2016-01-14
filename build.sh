#!/bin/bash

if (! $TRAVIS) then
    pushd "$(dirname "$0")"
fi

rm -rf artifacts
if ! type dnvm > /dev/null 2>&1; then
    curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh
fi

# work around restore timeouts on Mono
[ -z "$MONO_THREADS_PER_CPU" ] && export MONO_THREADS_PER_CPU=50

export DNX_UNSTABLE_FEED=https://www.myget.org/F/aspnetcidev/api/v2
dnvm update-self
dnvm upgrade -u
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
dnvm upgrade -u -r coreclr
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

dnvm use default -r coreclr
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

dnu restore
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

dnvm use default -r coreclr
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

pushd tests/OmniSharp.Bootstrap.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Dnx.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Plugins.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Roslyn.CSharp.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Stdio.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

dnvm use default -r mono
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

pushd tests/OmniSharp.Bootstrap.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Dnx.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Plugins.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Roslyn.CSharp.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Stdio.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.MSBuild.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd

pushd tests/OmniSharp.ScriptCs.Tests
dnx test -parallel none
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
popd


OMNISHARP_VERSION="1.0.0-dev";
if [ $TRAVIS_TAG ]; then
  OMNISHARP_VERSION=${TRAVIS_TAG:1};
fi

if [ $TRAVIS ]; then
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Host/project.json > src/OmniSharp.Host/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Abstractions/project.json > src/OmniSharp.Abstractions/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Bootstrap/project.json > src/OmniSharp.Bootstrap/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Dnx/project.json > src/OmniSharp.Dnx/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.MSBuild/project.json > src/OmniSharp.MSBuild/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Nuget/project.json > src/OmniSharp.Nuget/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Roslyn/project.json > src/OmniSharp.Roslyn/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Roslyn.CSharp/project.json > src/OmniSharp.Roslyn.CSharp/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.ScriptCs/project.json > src/OmniSharp.ScriptCs/project.json.temp
  jq '.version="'$OMNISHARP_VERSION'"' src/OmniSharp.Stdio/project.json > src/OmniSharp.Stdio/project.json.temp

  mv src/OmniSharp.Host/project.json.temp src/OmniSharp.Host/project.json
  mv src/OmniSharp.Abstractions/project.json.temp src/OmniSharp.Abstractions/project.json
  mv src/OmniSharp.Bootstrap/project.json.temp src/OmniSharp.Bootstrap/project.json
  mv src/OmniSharp.Dnx/project.json.temp src/OmniSharp.Dnx/project.json
  mv src/OmniSharp.MSBuild/project.json.temp src/OmniSharp.MSBuild/project.json
  mv src/OmniSharp.Nuget/project.json.temp src/OmniSharp.Nuget/project.json
  mv src/OmniSharp.Roslyn/project.json.temp src/OmniSharp.Roslyn/project.json
  mv src/OmniSharp.Roslyn.CSharp/project.json.temp src/OmniSharp.Roslyn.CSharp/project.json
  mv src/OmniSharp.ScriptCs/project.json.temp src/OmniSharp.ScriptCs/project.json
  mv src/OmniSharp.Stdio/project.json.temp src/OmniSharp.Stdio/project.json
fi

dnvm use default -r mono
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

dnu pack src/OmniSharp.Host --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Abstractions --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Bootstrap --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Dnx --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.MSBuild --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Nuget --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Roslyn --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Roslyn.CSharp --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.ScriptCs --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi
dnu pack src/OmniSharp.Stdio --configuration Release --out artifacts/build/nuget --quiet
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

dnvm use default -r coreclr
curl -LO http://nuget.org/nuget.exe

# omnisharp.tar.gz
dnu publish src/OmniSharp --configuration Release --no-source --out artifacts/build/omnisharp --runtime active
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

pushd artifacts/build/omnisharp/approot/packages/OmniSharp/1.0.0/root/
jq '.entryPoint="OmniSharp.Host"' project.json > project.json.temp
mv project.json.temp project.json
popd

# work around for kpm bundle returning an exit code 0 on failure
grep "Build failed" buildlog
rc=$?; if [[ $rc == 0 ]]; then exit 1; fi

mono nuget.exe install dnx-clr-win-x86 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp/approot/packages
find artifacts/build/omnisharp/approot/packages/dnx-clr-win-x86.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-win-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp/approot/packages
find artifacts/build/omnisharp/approot/packages/dnx-coreclr-win-x64.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-mono -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp/approot/packages
find artifacts/build/omnisharp/approot/packages/dnx-mono.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-linux-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp/approot/packages
find artifacts/build/omnisharp/approot/packages/dnx-coreclr-linux-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-darwin-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp/approot/packages
find artifacts/build/omnisharp/approot/packages/dnx-coreclr-darwin-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

tree -if artifacts/build/omnisharp | grep .nupkg | xargs rm
pushd artifacts/build/omnisharp
tar -zcf ../../../omnisharp.tar.gz .
popd

# omnisharp.bootstrap.tar.gz
# Publish just the bootstrap
dnu publish src/OmniSharp.Bootstrap --configuration Release --no-source --out artifacts/build/omnisharp.bootstrap --runtime active
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

# work around for kpm bundle returning an exit code 0 on failure
grep "Build failed" buildlog
rc=$?; if [[ $rc == 0 ]]; then exit 1; fi

mono nuget.exe install dnx-clr-win-x86 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp.bootstrap/approot/packages
find artifacts/build/omnisharp.bootstrap/approot/packages/dnx-clr-win-x86.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-win-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp.bootstrap/approot/packages
find artifacts/build/omnisharp.bootstrap/approot/packages/dnx-coreclr-win-x64.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-mono -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp.bootstrap/approot/packages
find artifacts/build/omnisharp.bootstrap/approot/packages/dnx-mono.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-linux-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp.bootstrap/approot/packages
find artifacts/build/omnisharp.bootstrap/approot/packages/dnx-coreclr-linux-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-darwin-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp.bootstrap/approot/packages
find artifacts/build/omnisharp.bootstrap/approot/packages/dnx-coreclr-darwin-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

tree -if artifacts/build/omnisharp.bootstrap | grep .nupkg | xargs rm
pushd artifacts/build/omnisharp.bootstrap
tar -zcf ../../../omnisharp.bootstrap.tar.gz .
popd

# omnisharp-coreclr.tar.gz
dnu publish src/OmniSharp --configuration Release --no-source --out artifacts/build/omnisharp-coreclr --runtime active
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

pushd artifacts/build/omnisharp-coreclr/approot/packages/OmniSharp/1.0.0/root/
jq '.entryPoint="OmniSharp.Host"' project.json > project.json.temp
mv project.json.temp project.json
popd

# work around for kpm bundle returning an exit code 0 on failure
grep "Build failed" buildlog
rc=$?; if [[ $rc == 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-win-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr/approot/packages
find artifacts/build/omnisharp-coreclr/approot/packages/dnx-coreclr-win-x64.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-linux-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr/approot/packages
find artifacts/build/omnisharp-coreclr/approot/packages/dnx-coreclr-linux-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-darwin-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr/approot/packages
find artifacts/build/omnisharp-coreclr/approot/packages/dnx-coreclr-darwin-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

tree -if artifacts/build/omnisharp-coreclr | grep .nupkg | xargs rm
pushd artifacts/build/omnisharp-coreclr
tar -zcf ../../../omnisharp-coreclr.tar.gz .
popd

# omnisharp-coreclr.bootstrap.tar.gz
# Publish just the bootstrap
dnu publish src/OmniSharp.Bootstrap --configuration Release --no-source --out artifacts/build/omnisharp-coreclr.bootstrap --runtime active
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

# work around for kpm bundle returning an exit code 0 on failure
grep "Build failed" buildlog
rc=$?; if [[ $rc == 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-win-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr.bootstrap/approot/packages
find artifacts/build/omnisharp-coreclr.bootstrap/approot/packages/dnx-coreclr-win-x64.1.0.0-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-linux-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr.bootstrap/approot/packages
find artifacts/build/omnisharp-coreclr.bootstrap/approot/packages/dnx-coreclr-linux-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

mono nuget.exe install dnx-coreclr-darwin-x64 -Version 1.0.0-rc2-16386 -Prerelease -Source https://www.myget.org/F/aspnetcidev/api/v2 -OutputDirectory artifacts/build/omnisharp-coreclr.bootstrap/approot/packages
find artifacts/build/omnisharp-coreclr.bootstrap/approot/packages/dnx-coreclr-darwin-x64.1.0.0-rc2-16386 -type d -maxdepth 0
rc=$?; if [[ $rc != 0 ]]; then exit 1; fi

tree -if artifacts/build/omnisharp-coreclr.bootstrap | grep .nupkg | xargs rm
pushd artifacts/build/omnisharp-coreclr.bootstrap
tar -zcf ../../../omnisharp-coreclr.bootstrap.tar.gz .
popd

tree artifacts

if (! $TRAVIS) then
    popd
fi
