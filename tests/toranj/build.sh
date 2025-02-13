#!/bin/bash
#
#  Copyright (c) 2018, The OpenThread Authors.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#

display_usage()
{
    echo ""
    echo "Toranj Build script "
    echo ""
    echo "Usage: $(basename "$0") [options] <config>"
    echo "    <config> can be:"
    echo "        all             : Build OpenThread NCP, CLI, and RCP with simulation platform"
    echo "        ncp             : Build OpenThread NCP mode with simulation platform"
    echo "        ncp-15.4        : Build OpenThread NCP mode with simulation platform - 15.4 radio"
    echo "        ncp-trel        : Build OpenThread NCP mode with simulation platform - TREL radio "
    echo "        ncp-15.4+trel   : Build OpenThread NCP mode with simulation platform - multi radio (15.4+TREL)"
    echo "        cli             : Build OpenThread CLI mode with simulation platform"
    echo "        cli-15.4        : Build OpenThread CLI mode with simulation platform - 15.4 radio"
    echo "        cli-trel        : Build OpenThread CLI mode with simulation platform - TREL radio "
    echo "        cli-15.4+trel   : Build OpenThread CLI mode with simulation platform - multi radio (15.4+TREL)"
    echo "        rcp             : Build OpenThread RCP (NCP in radio mode) with simulation platform"
    echo "        posix           : Build OpenThread POSIX"
    echo "        posix-15.4      : Build OpenThread POSIX - 15.4 radio"
    echo "        posix-trel      : Build OpenThread POSIX - TREL radio "
    echo "        posix-15.4+trel : Build OpenThread POSIX - multi radio (15.4+TREL)"
    echo ""
    echo "Options:"
    echo "        -c/--enable-coverage  Enable code coverage"
    echo ""
}

die()
{
    echo " *** ERROR: " "$*"
    exit 1
}

cd "$(dirname "$0")" || die "cd failed"
cd ../.. || die "cd failed"

ot_coverage=OFF

while [ $# -ge 2 ]; do
    case $1 in
        -c | --enable-coverage)
            ot_coverage=ON
            shift
            ;;
        -t | --enable-tests)
            shift
            ;;
        "")
            shift
            ;;
        *)
            echo "Error: Unknown option \"$1\""
            display_usage
            exit 1
            ;;
    esac
done

if [ "$#" -ne 1 ]; then
    display_usage
    exit 1
fi

build_config=$1

if [ -n "${top_builddir}" ]; then
    top_srcdir=$(pwd)
    mkdir -p "${top_builddir}"
else
    top_srcdir=.
    top_builddir=.
fi

case ${build_config} in
    ncp | ncp-)
        echo "==================================================================================================="
        echo "Building OpenThread NCP with simulation platform (radios determined by config)"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=OFF -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    ncp-15.4)
        echo "==================================================================================================="
        echo "Building OpenThread NCP with simulation platform - 15.4 radio"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=OFF -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/ncp/ot-ncp-ftd ${top_builddir}/examples/apps/ncp/ot-ncp-ftd-15.4
        ;;

    ncp-trel)
        echo "==================================================================================================="
        echo "Building OpenThread NCP with simulation platform - TREL radio"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=OFF -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=OFF -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/ncp/ot-ncp-ftd ${top_builddir}/examples/apps/ncp/ot-ncp-ftd-trel
        ;;

    ncp-15.4+trel | ncp-trel+15.4)
        echo "==================================================================================================="
        echo "Building OpenThread NCP with simulation platform - multi radio (15.4 + TREL)"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=OFF -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/ncp/ot-ncp-ftd ${top_builddir}/examples/apps/ncp/ot-ncp-ftd-15.4-trel
        ;;

    cli | cli-)
        echo "==================================================================================================="
        echo "Building OpenThread CLI with simulation platform (radios determined by config)"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=OFF -DOT_APP_RCP=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    cli-15.4)
        echo "==================================================================================================="
        echo "Building OpenThread CLI with simulation platform - 15.4 radio"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=OFF -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/cli/ot-cli-ftd ${top_builddir}/examples/apps/cli/ot-cli-ftd-15.4
        ;;

    cli-trel)
        echo "==================================================================================================="
        echo "Building OpenThread CLI with simulation platform - TREL radio"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=OFF -DOT_APP_RCP=OFF \
            -DOT_15_4=OFF -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/cli/ot-cli-ftd ${top_builddir}/examples/apps/cli/ot-cli-ftd-trel
        ;;

    cli-15.4+trel | cli-trel+15.4)
        echo "==================================================================================================="
        echo "Building OpenThread NCP with simulation platform - multi radio (15.4 + TREL)"
        echo "==================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=OFF -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        cp -p ${top_builddir}/examples/apps/cli/ot-cli-ftd ${top_builddir}/examples/apps/cli/ot-cli-ftd-15.4-trel
        ;;

    rcp)
        echo "===================================================================================================="
        echo "Building OpenThread RCP (NCP in radio mode) with simulation platform"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=OFF -DOT_APP_NCP=OFF -DOT_APP_RCP=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    posix | posix- | cmake-posix-host | cmake-posix | cmake-p)
        echo "===================================================================================================="
        echo "Building OpenThread POSIX (radios determined by config)"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=posix -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-posix.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    posix-15.4)
        echo "===================================================================================================="
        echo "Building OpenThread POSIX - 15.4 radio"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=posix -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=OFF \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-posix.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    posix-trel)
        echo "===================================================================================================="
        echo "Building OpenThread POSIX - TREL radio"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=posix -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=OFF -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-posix.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    posix-trel+15.4 | posix-15.4+trel)
        echo "===================================================================================================="
        echo "Building OpenThread POSIX - multi radio link (15.4 + TREL)"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=posix -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=ON -DOT_APP_RCP=OFF \
            -DOT_15_4=ON -DOT_TREL=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-posix.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    all | cmake)
        echo "===================================================================================================="
        echo "Building OpenThread (NCP/CLI for FTD/MTD/RCP mode) with simulation platform using cmake"
        echo "===================================================================================================="
        cd "${top_builddir}" || die "cd failed"
        cmake -GNinja -DOT_PLATFORM=simulation -DOT_COMPILE_WARNING_AS_ERROR=ON -DOT_COVERAGE=${ot_coverage} \
            -DOT_THREAD_VERSION=1.3.1 -DOT_APP_CLI=ON -DOT_APP_NCP=ON -DOT_APP_RCP=ON \
            -DOT_CONFIG=../tests/toranj/openthread-core-toranj-config-simulation.h \
            "${top_srcdir}" || die
        ninja || die
        ;;

    *)
        echo "Error: Unknown configuration \"$1\""
        display_usage
        exit 1
        ;;
esac

exit 0
