#include "stdafx.h"
#include "Bitmap.h"
#include "Algorithm.h"

using namespace std;

int getCoresCount() {
	SYSTEM_INFO sysinfo;
	GetSystemInfo(&sysinfo);
	return sysinfo.dwNumberOfProcessors;
}

int main()
{
	srand(time(NULL));
	clock_t start, stop;

	string fileName = "";
	cout << "Enter file path:" << endl;
	cin >> fileName;
	Bitmap bmp(fileName);
	BYTE *data = bmp.getPixelDataPointerBGR();
	cout << "Enter limit from range of <0 : 255>" << endl;
	BYTE limitB = 0;
	int limit = -1;
	while (limit > 255 || limit < 0) {
		cin >> limit;
	}

	limitB = limit;
	long size = bmp.getImageSize();

	for (int i = 1; i <= 20; i++) {
		if (bmp.isOpen()) {
			BYTE *data(bmp.getPixelDataPointerBGR());
			BYTE *result(bmp.getResultDataPointer());
			start = clock();
			//Algorithm::solarizeForNBytesUsingXCores(data, result, limitB, bmp.getImageSize(), i);
			Algorithm::solarizeForNBytesUsingXCoresASM(data, result, limitB, bmp.getImageSize(), i);
			stop = clock();
			bmp.saveBMPTo("img/result.bmp");
		}
		cout << i << " threads - ";
		cout << "duration: " << stop - start << "ms." << endl;
	}
	system("PAUSE");
	return 0;
}

