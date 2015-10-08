//拆分字符串
std::string utf8_to_charset(const std::string &input) {
	std::string ch;
	std::string strTemp;
	for (size_t i = 0, len = 0; i != input.length(); i += len) {
		unsigned char byte = (unsigned)input[i];
		if (byte >= 0xFC) // lenght 6     // 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc 
			len = 6;
		else if (byte >= 0xF8)
			len = 5;
		else if (byte >= 0xF0)
			len = 4;
		else if (byte >= 0xE0)
			len = 3;
		else if (byte >= 0xC0)
			len = 2;
		else
			len = 1;
		ch = input.substr(i, len);
		//output.insert(ch);

		strTemp += ch + " ";
	}
	//return output.size();
	return strTemp;
}

//wellbye
//可重演的随机数生成器
class RandGenerator{
	
	int initSeed;
	int curSeed;
	
public:
	RandGenerator(int s=cocos2d::random(0,65535)){ reset(s); }
	
	void reset(int s=cocos2d::random(0,65535)){
		if( curSeed==initSeed )
			return;
		
		initSeed = curSeed= s;
	}
	
	void resetLast(){
		curSeed = initSeed;
	}
	
	int	getNext(int f=0, int t=65535){
		int next = (curSeed * 9301 + 49297) % 233280;
		float rnd = next / (233280.f);
		int r =  floor( f + rnd * (t+1 - f) );
		curSeed = next;
		return r;
		
	}
};