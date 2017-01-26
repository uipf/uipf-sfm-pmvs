cmake_minimum_required(VERSION 3.0.0)
project(uipf-sfm-pmvs)

#c++11 support
if(${CMAKE_VERSION} VERSION_LESS 3.1.0)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++0x")
else()
	set(CMAKE_CXX_STANDARD 11)
endif()

if(UNIX)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

	# sanitize memory issues https://gcc.gnu.org/gcc-4.8/changes.html
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
endif()

message("CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message("CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
message("CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")

# bundler
include(ExternalProject)
# build bundler as external project
ExternalProject_Add(PMVS
	SOURCE_DIR ${uipf-sfm-pmvs_SOURCE_DIR}/pmvs-2/program
	CONFIGURE_COMMAND rsync -r ${uipf-sfm-pmvs_SOURCE_DIR}/pmvs-2/program .
		&& sed -i s~<clapack/~<~ program/base/numeric/mylapack.cc
		&& patch program/base/numeric/mylapack.h ${uipf-sfm-pmvs_SOURCE_DIR}/mylapack.h.patch
	# parallelize the build to be faster
	BUILD_COMMAND cd program/main && make depend -j 4 && make
	TEST_COMMAND ""
	INSTALL_COMMAND "" # skip install step for COLMAP
)
ExternalProject_Get_Property(PMVS binary_dir)
set(PMVS_BINARY_DIR "${binary_dir}")


# find libuipf-module
# search in normal system paths as well as installation prefix for installation as unprivileged user.
find_library(
	ModuleBase uipf-module
	PATHS ${CMAKE_INSTALL_PREFIX}/lib
)
message("ModuleBase: ${ModuleBase}")
include_directories(${ModuleBase_INCLUDE_DIRS})


add_library(PMVSModule SHARED src/PMVSModule.cpp)
target_link_libraries(PMVSModule ${ModuleBase})
add_dependencies(PMVSModule PMVS)

# installation targets
install(TARGETS
	PMVSModule

	LIBRARY DESTINATION lib/uipf
	ARCHIVE DESTINATION lib/uipf
)

# install headers
#install(DIRECTORY ${uipf-sfm-sift_SOURCE_DIR}/include
#	DESTINATION include/uipf-sfm/sift
#	FILES_MATCHING PATTERN "*.hpp"
#)

install(FILES ${PMVS_BINARY_DIR}/program/main/pmvs2
	DESTINATION bin/
	PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
	RENAME uipf-sfm-pmvs2
)
