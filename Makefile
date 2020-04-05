install:
	swift package update
	swift build -c release
	install .build/Release/SplashObjcHTMLGen /usr/local/bin/SplashObjcHTMLGen
	install .build/Release/SplashObjcImageGen /usr/local/bin/SplashObjcImageGen
	install .build/Release/SplashObjcTokenizer /usr/local/bin/SplashObjcTokenizer
