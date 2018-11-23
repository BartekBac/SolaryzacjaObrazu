#include "stdafx.h"
#include "Algorithm.h"

void Algorithm::solarize(BYTE *_data, const int limit) {
	if (int(*(_data)) >= limit) {
		*_data = 255 - *_data;
	}
}

void Algorithm::solarizeForNBytes(BYTE *_begin, const int limit, const int n)
{
	for (unsigned int i = 0; i < n; i++) {
		solarize((_begin + i), limit);
	}
}

void Algorithm::solarizeForNBytesUsingXCores(BYTE *_begin, const int limit, const int n, const int numberOfCores) {
	int size = n / numberOfCores;
	int rest = n % numberOfCores;
	int lastSize = size + rest;
	vector<BYTE*> begins(numberOfCores);
	for (int i = 0; i < numberOfCores; i++)
	{
		begins[i] = _begin + i*size;
	}
	vector<thread> threads;
	for (int i = 0; i < numberOfCores; i++)
	{
		int localSize = size;
		if (i == numberOfCores - 1) {
			localSize = lastSize;
		}

		threads.push_back(std::thread(&solarizeForNBytes, begins[i], limit, localSize));
	}
	for (int i = 0; i < numberOfCores; i++)
	{
		threads.at(i).join();
	}
}

void Algorithm::solarizeForNBytesUsingXCoresASM(BYTE *_begin, BYTE limit, long n, const int numberOfCores) {
	long size = n / numberOfCores;
	int rest = n % numberOfCores;
	long lastSize = size + rest;
	vector<BYTE*> begins(numberOfCores);
	for (int i = 0; i < numberOfCores; i++)
	{
		begins[i] = _begin + i*size;
	}
	vector<thread> threads;
	for (int i = 0; i < numberOfCores; i++)
	{
		long localSize = size;
		if (i == numberOfCores - 1) {
			localSize = lastSize;
		}

		threads.push_back(std::thread(&solarizeASM, begins[i], localSize, limit));
	}
	for (int i = 0; i < numberOfCores; i++)
	{
		threads.at(i).join();
	}
}