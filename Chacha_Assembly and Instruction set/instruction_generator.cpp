#include <iostream>
#include <bits/stdc++.h>
#include <string>
#include <bitset>
#include <fstream>
#include <unordered_map>
using namespace std;

unordered_map<string, string> register_map = {
    {"R1", "00001"},
    {"R2", "00010"},
    {"R3", "00011"},
    {"R4", "00100"},
    {"R5", "00101"},
    {"R6", "00110"},
    {"R7", "00111"},
    {"R8", "01000"},
    {"R9", "01001"},
    {"R10", "01010"},
    {"R11", "01011"},
    {"R12", "01100"},
    {"R13", "01101"},
    {"R14", "01110"},
    {"R15", "01111"},
    {"R16", "10000"},
    {"R17", "10001"},
    {"R18", "10010"},
    {"R19", "10011"},
    {"R20", "10100"},
    {"R21", "10101"},
    {"R22", "10110"},
    {"R23", "10111"},
    {"R24", "11000"},
    {"R25", "11001"},
    {"R26", "11010"},
    {"R27", "11011"},
    {"R28", "11100"},
    {"R29", "11101"},
    {"R30", "11110"},
    {"R31", "11111"}
};

void line_generator(const string path){
 string line;
 ifstream file(path);
 if (file.is_open()){
  int count = 0;
  while(getline(file,line)){
   stringstream str(line);
   string split;
   count += 1;
   string line = "";
   while(getline(str,split,' ')){
    string immediate;
    if(split=="keep") immediate="10000000";
    else if(split=="jump") immediate="10000001";
    else if(split=="remove") immediate="10000010";
    else if(split=="replace") immediate="10000011";
    else if(split=="intialize") immediate="10000100";
    else if(split=="add") immediate="10000101";
    else if(split=="substract") immediate="10000110";
    else if(split=="divide") immediate="10000111";
    else if(split=="multiply") immediate="10001000";
    else if(split=="right_shift") immediate="10001001";
    else if(split=="left_shift") immediate="10001010";
    else if(split=="move") immediate="10001011";
    else if(register_map.find(split)!=register_map.end())immediate = register_map[split];
    else immediate = "000000000";
   line += immediate + " " ;
  }
   cout<<"line number "<<count<<" :: "<<line<<endl;
  }
 }
}
int main(){
 string path;
 cout<<"Give the path :: ";
 cin>>path;
 line_generator(path);
 return 0;
}
