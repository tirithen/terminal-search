module searchfor.options;

import searchfor.search : SearchEngine;

struct Options {
  SearchEngine engine = SearchEngine.duckduckgo;
  bool clearCache = false;
  bool debugOptions = false;
  string query;
}

Options getOptionsOrPrintHelp(string[] argv) {
  import std : getopt, defaultGetoptPrinter;

  auto options = Options();

  auto helpInformation = getopt(argv, "engine|e",
      "[duckduckgo|google] Search engine to use (default duckduckgo)", &options.engine, "clear|c",
      "Clear the cache before searching (or exit on empty query)",
      &options.clearCache,
      "debug-options|d", "Print the current option values, only intended for debugging",
      &options.debugOptions);

  options.query = getQuery(argv);

  if (helpInformation.helpWanted) {
    import core.stdc.stdlib : exit;

    defaultGetoptPrinter("Usage: search [FLAG]... QUERY...\n\nSearch the web from the terminal.\n\nOptions:",
        helpInformation.options);
    exit(0);
  }

  if (options.debugOptions) {
    dump!options;
    dump!helpInformation;
  }

  return options;
}

private void dump(alias variable)() {
  import std.stdio : writeln;
  import std.traits : FieldNameTuple;

  writeln("Dumping ", typeid(typeof(variable)), ":\n");
  writeln(variable.stringof, " = \n{");
  foreach (member; FieldNameTuple!(typeof(variable))) {
    writeln("\t", member, ": ", mixin("variable." ~ member));
  }
  writeln("}\n");
}

string getQuery(string[] argv) {
  import std.array : join;
  import std.algorithm.searching : startsWith;

  string[] queryParts;
  foreach (argument; argv[1 .. $]) {
    if (!argument.startsWith("--")) {
      queryParts ~= argument;
    }
  }

  return join(queryParts, " ");
}
