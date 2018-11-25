// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

// #pragma once
#ifndef STDAFX_H
#define STDAFX_H


#include "targetver.h"

#include <stdio.h>
#include <tchar.h>



// TODO: reference additional headers your program requires here
#include <string>
#include <windows.h>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <thread>
#include <vector>
#include <time.h>

extern "C" int _stdcall solarizeASM(BYTE* data_ptr, long size, BYTE limit, BYTE* result_ptr);
#endif // !STDAFX_H