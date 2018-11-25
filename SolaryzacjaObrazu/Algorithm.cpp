#include "stdafx.h"
#include "Algorithm.h"

void Algorithm::solarize(BYTE *_data, BYTE *_result, const BYTE limit) {
	if (int(*(_data)) >= limit) {
		*_result = 255 - *_data;
	} else {
		*_result = *_data;
	}
}

void Algorithm::solarizeForNBytes(BYTE *_begin, BYTE *_result, const BYTE limit, const long n)
{
	for (unsigned int i = 0; i < n; i++) {
		solarize((_begin + i),(_result + i), limit);
	}
}

void Algorithm::solarizeForNBytesUsingXCores(BYTE *_begin, BYTE *_result, const BYTE limit, const long n, const int numberOfCores) {
	long size = n / numberOfCores;
	int rest = n % numberOfCores;
	long lastSize = size + rest;
	vector<BYTE*> begins(numberOfCores);
	vector<BYTE*> results(numberOfCores);
	for (int i = 0; i < numberOfCores; i++)
	{
		begins[i] = _begin + i*size;
		results[i] = _result + i*size;
	}
	vector<thread> threads;
	for (int i = 0; i < numberOfCores; i++)
	{
		long localSize = size;
		if (i == numberOfCores - 1) {
			localSize = lastSize;
		}

		threads.push_back(std::thread(&solarizeForNBytes, begins[i], results[i], limit, localSize));
	}
	for (int i = 0; i < numberOfCores; i++)
	{
		threads.at(i).join();
	}
}

void Algorithm::solarizeForNBytesUsingXCoresASM(BYTE *_begin, BYTE *_result, BYTE limit, const long n, const int numberOfCores) {
	long size = n / numberOfCores;
	int rest = n % numberOfCores;
	long firstSize = size + rest;
	vector<BYTE*> begins(numberOfCores);
	vector<BYTE*> results(numberOfCores);
	begins[0] = _begin;
	results[0] = _result;
	for (int i = 1; i < numberOfCores; i++)
	{
		if (i == 1) {
			begins[i] = _begin + firstSize;
			results[i] = _result + firstSize;
		} else {
			begins[i] = _begin + (i - 1)*size + firstSize;
			results[i] = _result + (i - 1)*size + firstSize;
		}
	}
	vector<thread> threads;
	for (int i = 0; i < numberOfCores; i++)
	{
		long localSize = size;
		if (i == 0) {
			localSize = firstSize;
		}
		threads.push_back(std::thread(&solarizeASM, begins[i], localSize, limit, results[i]));
	}
	for (int i = 0; i < numberOfCores; i++)
	{
		threads.at(i).join();
	}
}