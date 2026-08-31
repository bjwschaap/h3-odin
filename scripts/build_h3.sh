#!/bin/sh

set -eu

usage() {
	cat <<'EOF'
Build a native H3 static library for h3-odin.

Usage:
  scripts/build_h3.sh [--ref REVISION] [--output-dir DIRECTORY] H3_REPOSITORY

Arguments:
  H3_REPOSITORY          Path to a local clone or source tree of uber/h3.

Options:
  --ref REVISION         Build a local Git branch, tag, or commit without
                         changing the H3 checkout.
  --output-dir DIRECTORY Write the archive to DIRECTORY instead of _gen.
  -h, --help             Show this help text.

The output filename is selected from the native platform and architecture:
  libh3_{darwin,linux}_{amd64,arm64}.a
EOF
}

die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(dirname -- "$script_dir")
output_dir="$project_root/_gen"
revision=
h3_repository=

while [ "$#" -gt 0 ]; do
	case "$1" in
		--ref)
			[ "$#" -ge 2 ] || die "--ref requires a revision"
			revision=$2
			shift 2
			;;
		--output-dir)
			[ "$#" -ge 2 ] || die "--output-dir requires a directory"
			output_dir=$2
			shift 2
			;;
		-h | --help)
			usage
			exit 0
			;;
		--)
			shift
			break
			;;
		-*)
			die "unknown option: $1"
			;;
		*)
			[ -z "$h3_repository" ] || die "only one H3 repository may be specified"
			h3_repository=$1
			shift
			;;
	esac
done

if [ "$#" -gt 0 ]; then
	[ -z "$h3_repository" ] || die "only one H3 repository may be specified"
	[ "$#" -eq 1 ] || die "only one H3 repository may be specified"
	h3_repository=$1
fi

[ -n "$h3_repository" ] || {
	usage >&2
	exit 2
}
[ -d "$h3_repository" ] || die "H3 repository is not a directory: $h3_repository"

h3_repository=$(CDPATH= cd -- "$h3_repository" && pwd -P)
[ -f "$h3_repository/CMakeLists.txt" ] || \
	die "CMakeLists.txt not found in H3 repository: $h3_repository"

require_command cmake

case "$(uname -s)" in
	Darwin)
		platform=darwin
		;;
	Linux)
		platform=linux
		;;
	*)
		die "unsupported operating system: $(uname -s) (expected Darwin or Linux)"
		;;
esac

case "$(uname -m)" in
	x86_64 | amd64)
		architecture=amd64
		cmake_architecture=x86_64
		;;
	arm64 | aarch64)
		architecture=arm64
		cmake_architecture=arm64
		;;
	*)
		die "unsupported architecture: $(uname -m) (expected amd64 or arm64)"
		;;
esac

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/h3-odin-build.XXXXXX") || \
	die "could not create a temporary build directory"

cleanup() {
	if [ -n "${work_dir:-}" ] && [ -d "$work_dir" ]; then
		rm -rf -- "$work_dir"
	fi
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

source_dir=$h3_repository
source_description=$h3_repository

if [ -n "$revision" ]; then
	case "$revision" in
		-*) die "revision may not start with '-': $revision" ;;
	esac
	require_command git
	require_command tar
	git -C "$h3_repository" rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
		die "--ref requires H3_REPOSITORY to be a Git working tree"
	commit=$(git -C "$h3_repository" rev-parse --verify "${revision}^{commit}" 2>/dev/null) || \
		die "revision is not available in the local H3 clone: $revision"
	mkdir "$work_dir/source"
	git -C "$h3_repository" archive --format=tar --output="$work_dir/source.tar" "$commit"
	tar -xf "$work_dir/source.tar" -C "$work_dir/source"
	source_dir=$work_dir/source
	source_description="$revision ($commit)"
fi

build_dir=$work_dir/build

set -- \
	-S "$source_dir" \
	-B "$build_dir" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_TESTING=OFF \
	-DBUILD_BENCHMARKS=OFF \
	-DBUILD_FILTERS=OFF \
	-DBUILD_FUZZERS=OFF \
	-DBUILD_GENERATORS=OFF \
	-DENABLE_DOCS=OFF \
	-DENABLE_FORMAT=OFF \
	-DENABLE_LINTING=OFF

if [ "$platform" = darwin ]; then
	set -- "$@" "-DCMAKE_OSX_ARCHITECTURES=$cmake_architecture"
fi

printf 'Configuring H3 from %s\n' "$source_description"
cmake "$@"
cmake --build "$build_dir" --config Release --target h3 --parallel

archive_list=$work_dir/archives.txt
find "$build_dir" -type f -name libh3.a -print > "$archive_list"
archive_count=$(wc -l < "$archive_list" | tr -d ' ')
[ "$archive_count" -eq 1 ] || {
	printf 'Found these candidate archives:\n' >&2
	sed 's/^/  /' "$archive_list" >&2
	die "expected one libh3.a build artifact, found $archive_count"
}
archive=$(sed -n '1p' "$archive_list")
[ -s "$archive" ] || die "built archive is empty: $archive"

mkdir -p "$output_dir"
output_dir=$(CDPATH= cd -- "$output_dir" && pwd -P)
output_file=$output_dir/libh3_${platform}_${architecture}.a
cmake -E copy_if_different "$archive" "$output_file"

printf 'Built %s\n' "$output_file"
if command -v file >/dev/null 2>&1; then
	file "$output_file"
fi
