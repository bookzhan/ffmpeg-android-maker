# Script to download FFmpeg's source code
# Relies on FFMPEG_SOURCE_TYPE and FFMPEG_SOURCE_VALUE variables
# to choose the valid origin and version

# Exports SOURCES_DIR_ffmpeg - path where actual sources are stored

# Getting sources of a particular FFmpeg release.
# Same argument (FFmpeg version) produces the same source set.
function ensureSourcesTar() {
  FFMPEG_SOURCES=ffmpeg-${FFMPEG_SOURCE_VALUE}

  if [[ ! -d "$FFMPEG_SOURCES" ]]; then
    TARGET_FILE_NAME=ffmpeg-${FFMPEG_SOURCE_VALUE}.tar.bz2

    curl https://www.ffmpeg.org/releases/${TARGET_FILE_NAME} --output ${TARGET_FILE_NAME}
    tar xf ${TARGET_FILE_NAME} -C .
    rm ${TARGET_FILE_NAME}
  fi

  export SOURCES_DIR_ffmpeg=$(pwd)/${FFMPEG_SOURCES}
}

# Getting sources of a particular branch or a tag of FFmpeg's git repository.
# Same branch name may produce different source set,
# as the branch in origin repository may be updated in future.
# Git tags lead to stable states of the source code.
function ensureSourcesGit() {
  NAME_TO_CHECKOUT=${FFMPEG_SOURCE_VALUE}

  GIT_DIRECTORY=ffmpeg-git

  FFMPEG_SOURCES=$(pwd)/${GIT_DIRECTORY}

  if [[ ! -d "$FFMPEG_SOURCES" ]]; then
    git clone https://git.ffmpeg.org/ffmpeg.git ${GIT_DIRECTORY}
  fi

  cd ${GIT_DIRECTORY}
  git reset --hard

  git checkout $NAME_TO_CHECKOUT
  if [ ${FFMPEG_SOURCE_TYPE} = "GIT_BRANCH" ]; then
    # Forcing the update of a branch
    git pull origin $BRANCH
  fi

  # Additional logging to keep track of an exact commit to build
  echo "Commit to build:"
  git rev-parse HEAD

  export SOURCES_DIR_ffmpeg=${FFMPEG_SOURCES}
}

# Actual code
case ${FFMPEG_SOURCE_TYPE} in
	GIT_TAG)
    echo "Using FFmpeg git tag: ${FFMPEG_SOURCE_VALUE}"
		ensureSourcesGit
		;;
	GIT_BRANCH)
    echo "Using FFmpeg git repository and its branch: ${FFMPEG_SOURCE_VALUE}"
		ensureSourcesGit
		;;
	TAR)
		echo "Using FFmpeg source archive: ${FFMPEG_SOURCE_VALUE}"
    ensureSourcesTar
		;;
esac
