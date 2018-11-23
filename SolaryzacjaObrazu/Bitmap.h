#ifndef BITMAP_H
#define BITMAP_H

#include <stdlib.h>
#include <windows.h>

using namespace std;

class Bitmap {
private:
	// bitmap file header, standard Winblows format
	BITMAPFILEHEADER m_header;

	// bitmap information, like height, width, and pixel format
	BITMAPINFOHEADER m_info;

	// pixel data
	BYTE * m_bgr_data;
	BYTE * result_data;

	// size of allocated data
	long size;
public:

	Bitmap(const string &filePath);
	~Bitmap();

	bool isOpen();
	BYTE* getPixelDataPointerBGR();
	BYTE* getResultDataPointer();
	long getImageSize();
	void printPixelsBGR();
	void saveBMPTo(const string &filePatch);

};


#endif // !BITMAP_H