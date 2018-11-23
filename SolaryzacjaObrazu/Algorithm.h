#ifndef ALGORITHM_H
#define ALGORITHM_H

//#include <stdlib.h>
//#include <windows.h>

using namespace std;

class Algorithm {
public:
	static void solarize(BYTE *_data, const int limit);
	static void solarizeForNBytes(BYTE *_begin, const int limit, const int n);
	static void solarizeForNBytesUsingXCores(BYTE *_begin, const int limit, const int n, const int numberOfCores);
	static void solarizeForNBytesUsingXCoresASM(BYTE *_begin, BYTE limit, long n, const int numberOfCores);
};


#endif // !ALGORITHM_H