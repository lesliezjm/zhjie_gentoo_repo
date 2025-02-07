# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_BASE_VER="6.7"
K_FROM_GIT="yes"
ETYPE="sources"
CKV="${PVR/-r/-git}"
EGIT_BRANCH="rpi-${K_BASE_VER}.y"
EGIT_COMMIT="727f28402a8583983b32d61391b839db495e5a38"

K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="12"
K_EXP_GENPATCHES_NOUSE="1"

# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
inherit kernel-2 git-r3
detect_version
EXTRAVERSION="-networkaudio"

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
EGIT_REPO_URI="https://github.com/raspberrypi/linux.git"
SRC_URI="${GENPATCHES_URI}"

KEYWORDS="amd64 arm arm64"
IUSE="+naa +cachy +xanmod"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.6-r4"

src_unpack() {
	git-r3_src_unpack
	mv "${WORKDIR}/${PF}" "${S}"

	unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.base.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.extras.tar.xz
        unpack genpatches-${K_BASE_VER}-${K_GENPATCHES_VER}.experimental.tar.xz

	rm -rfv "${WORKDIR}"/10*.patch
	rm -rfv "${WORKDIR}"/5010_enable-cpu-optimizations-universal.patch
	rm -rfv "${S}/.git"
	mkdir "${WORKDIR}"/genpatch
	mv "${WORKDIR}"/*.patch "${WORKDIR}"/genpatch/
	unpack_set_extraversion
}

src_prepare() {
	cp -v "${FILESDIR}/${K_BASE_VER}-networkaudio" ${K_BASE_VER}-networkaudio

	# genpatch
	eapply "${WORKDIR}"/genpatch/*.patch

	# high-hz patch
	eapply "${FILESDIR}/0001-high-hz.patch"
	eapply "${FILESDIR}/0001-high-hz-1.patch"
	eapply "${FILESDIR}/0001-high-hz-2.patch"

	# naa patch
	if use naa; then
		eapply "${FILESDIR}"/naa/*.patch
	fi

	# EEVDF fixes from 6.8
	eapply "${FILESDIR}/sched-20231107-001-sort-the-rbtree-by-virtual-deadline.patch"
	eapply "${FILESDIR}/sched-20231107-002-O1-fastpath-for-task-selection.patch"
	eapply "${FILESDIR}/sched-20231122-avoid-underestimation-of-task-utilization.patch"
	eapply "${FILESDIR}/sched-20240226-return-leftmost-entity-in-pick_eevdf.patch"

	# cachy patch
	if use cachy; then
		eapply "${FILESDIR}/0001-cachyos-base-all-rpi.patch"
		eapply "${FILESDIR}/0001-lrng-rpi.patch"
	fi

	# xanmod patch
	if use xanmod; then
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0001-x86-vdso-Use-lfence-instead-of-rep-and-nop.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0002-sched-wait-Do-accept-in-LIFO-order-for-cache-efficie.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/intel/0004-locking-rwsem-spin-faster.patch"

		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0001-XANMOD-x86-build-Prevent-generating-avx2-and-avx512-.patch"
		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0002-XANMOD-x86-build-Add-more-x86-code-optimization-flag.patch"
		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0003-XANMOD-fair-Remove-all-energy-efficiency-functions.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0004-XANMOD-fair-Set-scheduler-tunable-latencies-to-unsca.patch"
		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0005-XANMOD-sched-core-Add-yield_type-sysctl-to-reduce-or.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0006-XANMOD-rcu-Change-sched_setscheduler_nocheck-calls-t.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0007-XANMOD-block-mq-deadline-Increase-write-priority-to-.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0008-XANMOD-block-mq-deadline-Disable-front_merges-by-def.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0009-XANMOD-block-set-rq_affinity-to-force-full-multithre.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0011-XANMOD-dcache-cache_pressure-50-decreases-the-rate-a.patch"
		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0012-XANMOD-mm-vmscan-vm_swappiness-30-decreases-the-amou.patch"
		# eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0013-XANMOD-sched-autogroup-Add-kernel-parameter-and-conf.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0014-XANMOD-cpufreq-tunes-ondemand-and-conservative-gover.patch"
		eapply "${FILESDIR}/xanmod/linux-6.7.y-xanmod/xanmod/0015-XANMOD-lib-kconfig.debug-disable-default-CONFIG_SYMB.patch"
	fi

        eapply_user
}
