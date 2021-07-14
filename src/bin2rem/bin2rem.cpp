// bin2rem version 2.1 - Jan 2008
// by Paolo Ferraris pieffe8_at_libero.it
// public domain

#include<stdio.h>
#include<iostream>
#include<string>

using namespace std;

int compatibility=0;
int wholeFile=0;
int wholeFile2=0;
int keywordNumber=0;
int visibleDigit=0;
int jump=0;
string inputFile="";
string outputFile="";
string fileName="";

const string keywords[50] = {"DEFFN","CAT","FORMAT","MOVE","ERASE","OPEN#",
			     "CLOSE#","MERGE","VERIFY","BEEP","CIRCLE","INK",
			     "PAPER","FLASH","BRIGHT","INVERSE","OVER","OUT",
			     "LPRINT","LLIST","STOP","READ","DATA","RESTORE",
			     "NEW","BORDER","CONTINUE","DIM","REM","FOR","GOTO",
			     "GOSUB","INPUT","LOAD","LIST","LET","PAUSE","NEXT",
			     "POKE","PRINT","PLOT","RUN","SAVE","RANDOMIZE",
			     "IF","CLS","DRAW","CLEAR","RETURN","COPY"};

void error(string s) {
  cerr<<s<<endl;
  exit(1);
}

void showSyntax() {
  cerr<<"Syntax: bin2rem [options] inputfile outputfile filename\n";
  cerr<<"\nMain options:\n";
  cerr<<"  -v1: same output as in version 1.0\n";
  cerr<<"  -j address: entry point of machine code (default: 23766)\n";
  cerr<<"  -k keyword: replace OVER with the specified keyword (no spaces)\n";

  cerr<<"\nAdvanced options:\n";
  cerr<<"  -w: BASIC block = input, bytes 5-11 are overwritten by a BASIC command\n";
  cerr<<"  -d digit: replace digit 7 with the specified digit\n";
  cerr<<"  -w2: as -w, but there is no overwriting\n";
  exit(1);
}

void parseCommandLine(int argc,char** argv) {
  int paramread=0;
  int cl;
  for(cl=1;cl<argc;cl++) {
    string param = argv[cl];
    if(param == "-v1") {
      compatibility = 1;
      continue;
    }
    if(param == "-w") {
      wholeFile = 1;
      continue;
    }
    if(param == "-w2") {
      wholeFile2 = 1;
      continue;
    }
    if(param == "-k") {
      if(keywordNumber)
	error("Option "+ param+ "already used.");
      if (cl==argc-1)
	error("Option -k must be followed by a keyword");
      string word = argv[++cl];
      for(int i=0;i<word.size();i++)
	if(word[i]>='a' && word[i]<='z')
	  word[i]+='A'-'a';
      for(int i=0;i<50;i++) {
	if(word == keywords[i])
	  keywordNumber = i + 206;
      }
      if(keywordNumber == 0)
	error("Keyword \"" + word + "\" unknown");
      continue;
    }
    if(param == "-d") {
      if(visibleDigit)
	error("Option "+ param+ "already used.");
      if (cl==argc-1)
	error("Option -d must be followed by a digit");
      string word = argv[++cl];
      if(word.size() !=1 || word[0]<'0' || word[0]>'9')
	error(word + " should be a digit");
      visibleDigit=word[0];
      continue;
    }
    if(param == "-j") {
      if(jump)
	error("Option "+ param+ "already used.");
      if (cl==argc-1)
	error("Option -j must be followed by a positive integer <65536.");
      string word = argv[++cl];
      if (word.size()>5)
	error("Option -j must be followed by a positive integer <65536.");
      for(int i=0;i<word.size();i++) {
	if(word[i]<'0' && word[i]>'9')
	  error("Option -j must be followed by a positive integer <65536.");
	jump=jump*10+word[i]-'0';
      }
      if (!jump || jump>65535)
	error("Option -j must be followed by a positive integer <65536.");
      continue;
    }
    if(param[0]=='-')
      error("Option "+param+" unknown.");
    switch(paramread++) {
    case 3:
      showSyntax();
    case 0:
      inputFile=param;
      break;
    case 1:
      outputFile=param;
      break;
    case 2:
      fileName=param;
      break;
    default:
      error("Unknown error");
    }
  }
  if (paramread != 3)
    showSyntax();
  if (fileName.size()>10)
    error("Filename "+fileName+" has more than 10 characters");
  while(fileName.size()<10)
    fileName+=' ';

  if(compatibility &&
     (wholeFile || wholeFile2 || keywordNumber || visibleDigit || jump))
    error("Compatibility option -c can't be used with any other option.");
  if(wholeFile && wholeFile2)
    error("At most one of the options -w and -w2 can be used.");
  if(wholeFile2 && (keywordNumber || visibleDigit || jump))
    error("Options -j, -d and -k cannot be used with -w2.");
  if(!keywordNumber)
    keywordNumber = 222;
  if(!visibleDigit)
    visibleDigit = '7';
  if(!jump)
    jump = 23766;
}

string word2chars(int num) {
  return string(1,num%256) + char(num/256);
}


void writeBlock (string stringa, int tipo, FILE* fil) {
  string st=string(1,tipo)+stringa;
  int chksum = 0;
  for(int z=0;z<st.size();z++)
    chksum= chksum^st[z];
  st = word2chars(st.size() + 1) + st + char(chksum);
  for(int z=0;z<st.size();z++)
    putc(st[z],fil);
}

void writeTap(string output,string filename,string outputFile) {
  int autorun = 0;

  FILE* fout=fopen(outputFile.c_str(),"wb");
  if(!fout)
    error("Error opening the output file `"+outputFile+"'");

  string header = string(1,0) + filename + word2chars(output.size())
    + word2chars(autorun) + word2chars(output.size());
  writeBlock(header,0,fout);
  writeBlock(output,255,fout);

  fclose(fout);
}

int main(int argc,char** argv) {
  int z,v,u;
  FILE* fin;
  FILE* fout;

  parseCommandLine(argc, argv);

  fin=fopen(inputFile.c_str(),"rb");
  if(!fin)
    error("Error opening the input file `"+inputFile+"'");
  string input;
  while((v=getc(fin))!=EOF)
    input+=char(v);
  fclose(fin);

  if(!input.size())
    error("Input file should not be empty");

  string basicHeader="";
  string output="";
  if (compatibility) {
    basicHeader+=249; // RANDOMIZE
    basicHeader+=192; // USR
    basicHeader+='0';
    basicHeader+=14;  // number begins
    basicHeader+=char(0);
    basicHeader+=char(0);
    basicHeader+=word2chars(23769);
    basicHeader+=char(0);
    basicHeader+=':';
    output = string(4,0)+ basicHeader + input;
  } else if (wholeFile2)
    output = input;
  else {
    string lineNumberLength=string(4,0);
    string machineCode=input;
    if(wholeFile) {
      if(input.size()<12)
	input+=string(12-input.size(),0);
      lineNumberLength=input.substr(0,4);
      machineCode=input.substr(11);
    }

    basicHeader+=keywordNumber;
    basicHeader+=192; // USR
    basicHeader+=visibleDigit;
    basicHeader+=14;  // number begins

    // we need to compute a FP number that, when rounded, gives jump.
    // normally we have 4 bytes for the mantissa, but 2 bytes are actually
    // sufficient to get any integer <65536.
    int exp = 128+16; // exp = exponent
    int mant = jump; // mant = two most significant bytes of mantissa
    if (mant<32768)
      // 15-bit number or less. We can have at least 1 bit for the decimal
      // part. If we set those bits to 0 then there is no risk of rounding up.
      // We just need to normalize the mantissa.
      while(mant<32768) {
	exp--;
	mant*=2;
      }
    else
      // 16-bit number. Mantissa is already normalized, but
      // we need to check if a bit of the input makes the number
      // round up. In this case, we decrease mant
      if (machineCode[0] & 128) {
	mant--;
	// normally mant is still normalized, so we are done. The only
        // exception is when jump = 32768 so that mant = 32767.
	// We transform the FP number into 32767.5 .
	if(mant == 32767) {
	  mant=mant*2+1;
	  exp--;
	}
      }
    mant-=32768;     // discard the most significant bit of mantissa
    // write the number
    basicHeader += exp;
    basicHeader += mant/256;
    basicHeader += mant%256;

    output = lineNumberLength+basicHeader+machineCode;
  }
  if(output[0]>=64)
    error("If option -w or -w2 is used, the first byte of input must be <64.");

  writeTap(output,fileName,outputFile);

}
