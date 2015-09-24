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