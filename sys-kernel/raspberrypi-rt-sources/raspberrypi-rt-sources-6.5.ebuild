# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.5"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"

K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"
K_EXP_GENPATCHES_NOUSE="1"
# K_NODRYRUN="1"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"

inherit kernel-2 git-r3
detect_version

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.6-r4"

EXTRAVERSION="-raspberrypi-rt"
S="${WORKDIR}/linux-${K_BASE_VER}${EXTRAVERSION}"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	echo ${S}

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz
	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${S}/.git"

}

src_prepare() {
	# genpatch
	eapply "${WORKDIR}"/*.patch

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# cachy patch
	if use cachy; then
	        eapply "${FILESDIR}/cachy/6.5/all/0001-cachyos-base-all.patch"
		eapply "${FILESDIR}/cachy/6.5/misc/0001-high-hz.patch"
	        eapply "${FILESDIR}/cachy/6.5/misc/0001-lrng.patch"
	fi

	# rt patch
        eapply "${FILESDIR}/cachy/6.5/misc/0001-rt.patch"
	eapply "${FILESDIR}/rt-arm-arm64-6.5.patch"

	# xanmod patch
	if use xanmod; then
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"
	        eapply "${FILESDIR}/xanmod/linux-6.5.y-xanmod/futex/0001-futex-Add-entry-point-for-FUTEX_WAIT_MULTIPLE-opcode.patch"
	fi

        eapply_user
}
