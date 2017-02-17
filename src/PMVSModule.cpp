
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
		{"rootdir", uipf::ParamDescription("working directory where key files will be read from and be placed.")}, \
		{"level", uipf::ParamDescription("", true)}, \
		{"csize", uipf::ParamDescription("", true)}, \
		{"threshold", uipf::ParamDescription("", true)}, \
		{"wsize", uipf::ParamDescription("", true)}, \
		{"minImageNum", uipf::ParamDescription("", true)}, \
		{"CPU", uipf::ParamDescription("", true)}, \
		{"minImageNum", uipf::ParamDescription("", true)}, \
		{"sequence", uipf::ParamDescription("", true)}, \
		{"quad", uipf::ParamDescription("", true)}, \
		{"maxAngle", uipf::ParamDescription("", true)}, \
		{"matchThreshold", uipf::ParamDescription("Only consider those images that have more than these number of corrsp. points. Default 32.", true)}
// TODO more docs http://www.di.ens.fr/pmvs/documentation.html

#include <uipf/Module.hpp>


// TODO configure this path with cmake
#define PMVS_BINARY "uipf-sfm-pmvs2"

using namespace uipf;
using namespace uipf::data;
using namespace uipfsfm::data;

/**
 * @return whether a matrix is different from 0.
 */
bool isZero(cv::Matx34d m) {
	for(double d: m.val) {
		if (d > 0.0001 || d < -0.0001) {
			return false;
		}
	}
	return true;
}

/**
 * http://www.di.ens.fr/pmvs/documentation.html
 */
void PMVSModule::run() {

	using namespace std;
	namespace fs = boost::filesystem;

	ImageGraph::ptr imageGraph = getInputData<ImageGraph>("imageGraph");
	fs::path rootdir = fs::absolute(fs::path(getParam<string>("rootdir", ".")));

	fs::path imagePath = rootdir / fs::path("visualize");
	if (!fs::exists(imagePath)) {
		// TODO error handling
		fs::create_directories(imagePath);
	}
	fs::path txtPath = rootdir / fs::path("txt");
	if (!fs::exists(txtPath)) {
		// TODO error handling
		fs::create_directories(txtPath);
	}
	fs::path modelsPath = rootdir / fs::path("models");
	if (!fs::exists(modelsPath)) {
		// TODO error handling
		fs::create_directories(modelsPath);
	}


	// list of mapping original image files names with pmvs file names
	// oldName -> newName
	map<string, string> imageMap;

	int i = 0;
	for(auto image: imageGraph->images) {

		char s[13];
		sprintf(s, "%08d.jpg", i);
		fs::path newName = imagePath / fs::path(s);
		fs::path oldName(image.second->getContent());

		if (oldName.has_extension() && oldName.extension().string() == ".jpg") {
			// TODO error handling
			if (fs::exists(newName)) {
				fs::remove(newName);
			}
			fs::copy(oldName, newName);
		} else {
			// TODO consider using different formats, e.g. jpg/pgm
			// http://www.di.ens.fr/pmvs/documentation.html
			OpenCVMat::ptr img = load_image_color(oldName.string());
			img->store(newName.string());
		}

		// write P matrix to file according to http://www.di.ens.fr/pmvs/documentation.html
		cv::Matx34d P = image.second->P;
		char st[13];
		sprintf(st, "%08d.txt", i);
		fs::path txtFileName = txtPath / fs::path(st);
		ofstream txtFile(txtFileName.string());
		txtFile << "CONTOUR\n";
		txtFile << P(0, 0) << " " << P(0, 1) << " " << P(0, 2) << " " << P(0, 3) << "\n";
		txtFile << P(1, 0) << " " << P(1, 1) << " " << P(1, 2) << " " << P(1, 3) << "\n";
		txtFile << P(2, 0) << " " << P(2, 1) << " " << P(2, 2) << " " << P(2, 3) << "\n";
		txtFile.close();

		imageMap.insert(pair<string, string>(oldName.string(), newName.string()));

		i++;
	}


	vector<int> timages;
	vector<int> oimages;
	for(auto img: imageGraph->images) {
		if (img.second->hasProjectionMatrix && !isZero(img.second->P)) {
			timages.push_back(img.first);
		} else {
			oimages.push_back(img.first);
		}
	}



	// generate options file
	fs::path optionsFileName = rootdir / fs::path("options.txt");
	ofstream optionsFile(optionsFileName.string());

	optionsFile << "timages " << timages.size();
	for(int iid: timages) {
		optionsFile << " " << iid;
	}
	optionsFile << "\n";
	optionsFile << "oimages 0";
//	optionsFile << "oimages " << oimages.size();
//	for(int iid: oimages) {
//		optionsFile << " " << iid;
//	}
	optionsFile << "\n";
	optionsFile << "useVisData 1\n";

	int paramLevel = getParam<int>("level", 1);
	optionsFile << "level " << paramLevel << "\n";
	int paramCsize = getParam<int>("csize", 2);
	optionsFile << "csize " << paramCsize << "\n";
	double paramThreshold = getParam<double>("threshold", 0.7);
	optionsFile << "threshold " << paramThreshold << "\n";
	int paramWsize = getParam<int>("wsize", 7);
	optionsFile << "wsize " << paramWsize << "\n";
	int paramMinImageNum = getParam<int>("minImageNum", 3);
	optionsFile << "minImageNum " << paramMinImageNum << "\n";
	int paramCPU = getParam<int>("CPU", 4);
	optionsFile << "CPU " << paramCPU << "\n";
	int paramSequence = getParam<int>("sequence", -1);
	optionsFile << "sequence " << paramSequence << "\n";
	double paramQuad = getParam<double>("quad", 2.5);
	optionsFile << "quad " << paramQuad << "\n";
	int paramMaxAngle = getParam<int>("maxAngle", 10);
	optionsFile << "maxAngle " << paramMaxAngle << "\n";

	optionsFile.close();

	int matchThreshold = getParam<int>("matchThreshold", 32);

	// create useVisData file
	fs::path visFileName = rootdir / fs::path("vis.dat");
	ofstream visFile(visFileName.string());

	visFile << "VISDATA" << "\n";
	visFile << imageGraph->images.size() << "\n";
	for(auto image: imageGraph->images) {
		visFile << image.first;
		vector<int> v;
		for(ImagePair::ptr ipair: imageGraph->getContent()) {
			if (!ipair->hasKeyPointMatches || ipair->keyPointMatches.size() < matchThreshold) {
				continue;
			}
			if (image.second == ipair->getContent().first) {
				for(auto im: imageGraph->images) {
					if (im.second == ipair->getContent().second) {
						v.push_back(im.first);
						break;
					}
				}
			}
			if (image.second == ipair->getContent().second) {
				for(auto im: imageGraph->images) {
					if (im.second == ipair->getContent().first) {
						v.push_back(im.first);
						break;
					}
				}
			}
		}
		visFile << " " << v.size();
		for(int vi: v) {
			visFile << " " << vi;
		}
		visFile << "\n";
	}

	visFile.close();


//	fs::path oldcwd = fs::absolute(fs::current_path());
//	chdir(rootdir.c_str());
	UIPF_LOG_WARNING((string(PMVS_BINARY) + string(" ") + rootdir.string() + string("/ ") + optionsFileName.filename().string()).c_str());
	int ret = system((string(PMVS_BINARY) + string(" ") + rootdir.string() + string("/ ") + optionsFileName.filename().string()).c_str());
//	chdir(oldcwd.string().c_str());

	if (ret != 0) {
		throw ErrorException("pmvs exited non-zero");
	}

}








