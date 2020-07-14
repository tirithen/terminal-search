module searchfor.search;

enum SearchEngine {
  duckduckgo = "duckduckgo",
  google = "google"
};

struct SearchResult {
  string title;
  string description;
  string url;
}

SearchResult[] search(string query, SearchEngine engine = SearchEngine.duckduckgo) {
  import searchfor.engines.google : googleSearch;
  import searchfor.engines.duckduckgo : duckduckgoSearch;
  import searchfor.cache : cacheRead, cacheWrite;

  SearchResult[] searchResults;

  const cacheKey = query ~ "|" ~ engine;
  const cachedSearchResults = cacheRead!(SearchResult[])(cacheKey);
  if (cachedSearchResults.isNull) {
    if (engine == SearchEngine.google) {
      searchResults = googleSearch(query);
    } else {
      searchResults = duckduckgoSearch(query);
    }

    if (searchResults.length > 0) {
      cacheWrite(cacheKey, searchResults);
    }
  } else {
    searchResults = cast(SearchResult[]) cachedSearchResults.get;
  }

  return searchResults;
}
