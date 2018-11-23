// FirstSteps.cpp : Defines the entry point for the console application.
//

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
	Bitmap bmp("img/test_2_153_input.bmp");
	//BYTE *data(bmp.getPixelDataPointerBGR());
	BYTE *data = bmp.getPixelDataPointerBGR();
	int limit = 208;
	BYTE limitB = 128;
	//DWORD64 *a = new DWORD64(1000);
	//bmp.printPixelsBGR();
	long size = bmp.getImageSize();


	// cout << "data_dat :: " << "B: " << int(*(data)) << ", " << "G: " << int(*(data+1)) << ", " << "R: " << int(*(data+2)) << endl;


	// cout << getPointer(data, size, limitB);

	//solarizeASM(data, size, limitB);
	Algorithm::solarizeForNBytesUsingXCoresASM(data, limitB, size, 100);

	///
	// TODO: zrobiæ ¿eby dane by³y zapisywane na inny wskaŸnik danych, wtedy (nak³adanie paddingu siê rozwi¹¿e)
	// Ale wtedy funkcje w CPP trzeba poprawiæ
	///

	// cout << "data_dat :: " << "B: " << int(*(data)) << ", " << "G: " << int(*(data + 1)) << ", " << "R: " << int(*(data + 2)) << endl;

	bmp.saveBMPTo("img/testASM2.bmp");

	/*cout << "Cores count: " << getCoresCount() << endl;
	if (bmp.isOpen()) {
		BYTE *data(bmp.getPixelDataPointerBGR());
		Algorithm::solarizeForNBytesUsingXCores(data, limit, bmp.getImageSize(), getCoresCount());
		bmp.saveBMPTo("img/testCPP.bmp");
		cout << "Done." << endl;
	}*/
	cout << "Done." << endl;
	getchar();
	return 0;
}

