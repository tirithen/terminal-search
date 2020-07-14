module searchfor.app;

import searchfor.cache : cacheRead, cacheWrite;
import searchfor.search : search, SearchResult;

string getContent(string url) {
	import core.time : days;
	import searchfor.content : getPageContent;
	import std.stdio;

	string content;

	const cachedContent = cacheRead!string(url, 1.days);

	if (cachedContent.isNull) {
		content = getPageContent(url);
		cacheWrite(url, content);
	} else {
		content = cast(string) cachedContent.get;
	}

	return content;
}

void main(string[] argv) {
	import searchfor.options : getOptionsOrPrintHelp;

	auto options = getOptionsOrPrintHelp(argv);

	if (options.clearCache) {
		import core.stdc.stdlib : exit;
		import searchfor.cache : cacheClear;

		cacheClear();

		if (options.query.length == 0) {
			exit(0);
		}
	}

	if (options.query.length == 0) {
		import std.stdio : writeln;
		import core.stdc.stdlib : exit;

		writeln("Empty query, run \"search --help\" for help");
		exit(1);
	}

	auto searchResults = search(options.query, options.engine);
	if (searchResults.length == 0) {
		throw new Error("No search results found for query: " ~ options.query);
	}

	string content;
	string source;
	foreach (searchResult; searchResults) {
		source = searchResult.url;
		content = getContent(source);
		if (content.length > 0) {
			break;
		}
	}

	import arsd.terminal : Terminal, ConsoleOutputType, Color;

	auto terminal = Terminal(ConsoleOutputType.linear);
	terminal.color(Color.black, Color.white);
	terminal.write("Source: ", source);
	terminal.color(Color.DEFAULT, Color.DEFAULT);
	terminal.writeln("\n\n" ~ content);
}
