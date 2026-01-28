#!/usr/bin/env nu

print 'TIP: This script must be run from the project root directory'
print 'Usage: nu scripts/darwin-build.nu [--target <target>]'
print 'Options:'
print '  --target <target>  Build target: amd64, arm64, or all (default: all)'
print ''

def main [
    --target: string = 'all'  # Build target: amd64, arm64, or all
] {
    # Validate target
    if $target not-in ['amd64', 'arm64', 'all'] {
        print $"Error: Invalid target '($target)'"
        print 'Valid targets are: amd64, arm64, all'
        exit 1
    }

    # fnm use 24

    print 'Building UI'
    cd app
    pnpm install
    pnpm run build

    cd ..

    print 'Cleaning Builds'
    rm -rf app/build
    rm -rf app/kernel-darwin
    rm -rf app/kernel-darwin-arm64

    print 'Building Kernel'
    cd kernel
    go version

    $env.GO111MODULE = 'on'
    # $env:GOPROXY = 'https://goproxy.io'
    $env.GOPROXY = 'https://mirrors.aliyun.com/goproxy/'
    $env.CGO_ENABLED = '1'

    go mod tidy
    go generate
    # goversioninfo -platform-specific=true -icon=resource/icon.ico -manifest=resource/goversioninfo.exe.manifest

    if $target == 'amd64' or $target == 'all' {
        print 'Building Kernel amd64'
        $env.GOOS = 'darwin'
        $env.GOARCH = 'amd64'
        go build --tags fts5 -v -o "../app/kernel-darwin/SiYuan-Kernel" -ldflags "-s -w" .
    }

    if $target == 'arm64' or $target == 'all' {
        print 'Building Kernel arm64'
        $env.GOOS = 'darwin'
        $env.GOARCH = 'arm64'
        go build --tags fts5 -v -o "../app/kernel-darwin-arm64/SiYuan-Kernel" -ldflags "-s -w" .
    }

    cd ..

    cd app

    if $target == 'amd64' or $target == 'all' {
        print 'Building Electron App amd64'
        pnpm run dist-darwin
    }

    if $target == 'arm64' or $target == 'all' {
        print 'Building Electron App arm64'
        pnpm run dist-darwin-arm64
    }

    cd ..

    # fnm use 20
}
