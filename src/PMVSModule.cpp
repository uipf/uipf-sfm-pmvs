
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <boost/filesystem.hpp>
#include <algorithm>

#include <uipf/logging.hpp>
#include <uipf/data/opencv.hpp>
#include <uipf/util.hpp>

#include <uipf-sfm/data/KeyPointList.hpp>
#include <uipf-sfm/data/Image.hpp>
#include <uipf-sfm/data/ImageGraph.hpp>

#define UIPF_MODULE_NAME "PMVS"
#define UIPF_MODULE_ID "cebe.sfm.pmvs"
#define UIPF_MODULE_CLASS PMVSModule
#define UIPF_MODULE_CATEGORY "sfm"

// TODO with annotated geometry information
#define UIPF_MODULE_INPUTS \
		{"imageGraph", uipf::DataDescription(uipfsfm::data::ImageGraph::id(), "the image graph with matching image pairs.")}

//#define UIPF_MODULE_OUTPUTS \
//		{"imageGraph", uipf::DataDescription(uipfsfm::data::ImageGraph::id(), "the image graph with matching image pairs.")}

// TODO workdir could be just a temporary directory
#define UIPF_MODULE_PARAMS \
		{"rootdir", uipf::ParamDescription("working directory where key files will be read from and be placed.")}

// TODO param $MATCH_WINDOW_RADIUS

#include <uipf/Module.hpp>


// TODO configure this path with cmake
#define PMVS_BINARY "uipf-sfm-pmvs2"

using namespace uipf;
using namespace uipf::data;
using namespace uipf::util;
using namespace uipfsfm::data;

/**
 * http://www.di.ens.fr/pmvs/documentation.html
 */
void PMVSModule::run() {

	using namespace std;
	namespace fs = boost::filesystem;

	ImageGraph::ptr imageGraph = getInputData<ImageGraph>("imageGraph");

	// generate image list
	vector<string> imageList;
	uipf_foreach(imagePair, imageGraph->getContent()) {

		Image::ptr imageA = (*imagePair)->getContent().first;
		Image::ptr imageB = (*imagePair)->getContent().second;

		imageList.push_back(imageA->getContent());
		imageList.push_back(imageB->getContent());
	}
	// make sure image list is sorted to ensure IDs are preserved
	sort(imageList.begin(), imageList.end());
	imageList.erase( unique( imageList.begin(), imageList.end() ), imageList.end() );

	fs::path workdir = fs::absolute(fs::path(getParam<string>("workdir", ".")));

	string imageListFileName = (workdir / fs::path("image_list.txt")).string();
	ofstream imageListFile(imageListFileName);
	uipf_cforeach(i, imageList) {
		imageListFile << (fs::absolute(fs::path(*i))).string() << "\n";


		// TODO store P matrix for each image

	}
	imageListFile.close();


	// generate options file
	string optionsFileName = (workdir / fs::path("options.txt")).string();
	ofstream optionsFile(optionsFileName);

	// TODO create options file

	// TODO create useVisData file


	optionsFile.close();


	fs::path oldcwd = fs::absolute(fs::current_path());
	chdir(workdir.c_str());
	system((string(PMVS_BINARY) + string(" ") + imageListFileName + string(" --options_file ") + optionsFileName).c_str());
	chdir(oldcwd.string().c_str());


}








