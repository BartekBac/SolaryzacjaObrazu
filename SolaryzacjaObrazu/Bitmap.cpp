#include "stdafx.h"
#include "Bitmap.h"

Bitmap::Bitmap(const string &filePath) {
	// need an input stream variable for file operations
	ifstream fin;

	// initialize pointer
	m_bgr_data = 0;
	result_data = 0;

	// attempt to open the file using binary access
	fin.open(filePath, ios::binary);

	if (fin.is_open())
	{
		// read in the file info
		fin.read((char *)(&this->m_header), sizeof(BITMAPFILEHEADER));
		fin.read((char *)(&this->m_info), sizeof(BITMAPINFOHEADER));
		
		// fix size to 8 bytes padding
		int padding = this->m_info.biSizeImage % 8;
		this->size = this->m_info.biSizeImage + padding;

		// create an array that can take the pixel data
		//m_bgr_data = new BYTE[m_info.biSizeImage];
		m_bgr_data = new BYTE[this->size];
		result_data = new BYTE[this->size];

		// read the pixels in bgr format (we can read without padding)
		fin.read((char *)(m_bgr_data), m_info.biSizeImage);

		// close the file
		fin.close();
	}
	else
	{
		// post file not found message
		cout << "File path " << filePath << " is incorrect or does not exist." << endl;
	}
}

bool Bitmap::isOpen() {
	if (this->m_bgr_data) {
		return true;
	}
	else {
		return false;
	}
}

Bitmap::~Bitmap() {
	// deallocate arrays, if they were successfully allocated
	if (m_bgr_data)
	{
		delete[] m_bgr_data;
	}
	if (result_data)
	{
		delete[] result_data;
	}
}

void Bitmap::printPixelsBGR() {

	BYTE* src(m_bgr_data);
	cout << "B: " << int(*(src)) << " G: " << int(*(src + 1)) << " R: " << int(*(src + 2)) << endl;
	/*for (unsigned int index(0); index < m_info.biSizeImage / 3; index++, src += 3) {
		cout << "B: " << int(*(src)) << " G: " << int(*(src + 1)) << " R: " << int(*(src + 2)) << endl;
	}*/

}

BYTE* Bitmap::getPixelDataPointerBGR() {
	return this->m_bgr_data;
}

BYTE* Bitmap::getResultDataPointer() {
	return this->result_data;
}

long Bitmap::getImageSize() {
	// return m_info.biSizeImage;
	return this->size;
}

void Bitmap::saveBMPTo(const string &filePath) {
	// attempt to open the file specified
	ofstream fout;

	// attempt to open the file using binary access
	fout.open(filePath, ios::binary);

	//unsigned int number_of_bytes(m_info.biWidth * m_info.biHeight * 3);
	// m.info.biImageSize - include fixed to 4-bytes bmp size information
	unsigned int number_of_bytes = this->m_info.biSizeImage;
	BYTE red(0), green(0), blue(0);

	if (fout.is_open())
	{
		// same as before, only outputting now
		fout.write((char *)(&m_header), sizeof(BITMAPFILEHEADER));
		fout.write((char *)(&m_info), sizeof(BITMAPINFOHEADER));

		// read off the color data in the bass ackwards MS way
		for (unsigned int index(0); index < number_of_bytes; index += 3)
		{
			red = m_bgr_data[index + 2];
			green = m_bgr_data[index + 1];
			blue = m_bgr_data[index];

			fout.write((const char *)(&blue), sizeof(blue));
			fout.write((const char *)(&green), sizeof(green));
			fout.write((const char *)(&red), sizeof(red));
		}

		// close the file
		fout.close();
	}
	else
	{
		// post file not found message
		cout << "Incorrect destination path: " << filePath << endl;
	}
}