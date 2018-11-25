#ifndef ALGORITHM_H
#define ALGORITHM_H

//#include <stdlib.h>
//#include <windows.h>

using namespace std;

class Algorithm {
public:
	static void solarize(BYTE *_data, BYTE *_result, const BYTE limit);
	static void solarizeForNBytes(BYTE *_begin, BYTE *_result, const BYTE limit, const long n);
	static void solarizeForNBytesUsingXCores(BYTE *_begin, BYTE *_result, const BYTE limit, const long n, const int numberOfCores);
	static void solarizeForNBytesUsingXCoresASM(BYTE *_begin, BYTE *_result, BYTE limit, const long n, const int numberOfCores);
};


#endif // !ALGORITHM_H