module searchfor.engines.google;

import searchfor.search : SearchResult;

private const defaultUserAgent = "Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0";

SearchResult[] googleSearch(string query, string userAgent = defaultUserAgent) {
  SearchResult[] results;

  try {
    import std.uri : encode;
    import std.string : strip;

    import arsd.dom : Document;
    import arsd.http2 : HttpClient, Uri, HttpVerb;

    const url = "https://www.google.com/search?q=" ~ query.encode;

    auto client = new HttpClient();
    client.userAgent = userAgent;

    auto request = client.navigateTo(Uri(url), HttpVerb.GET);
    const response = request.waitForCompletion();

    auto document = new Document();
    document.parseGarbage(cast(string) response.content);

    foreach (element; document.querySelectorAll("div.rc")) {
      auto heading = element.querySelector("h3");
      auto description = element.querySelector(".st");
      auto link = element.querySelector("a");
      results ~= SearchResult(heading.innerText.strip,
          description.innerText.strip, link.getAttribute("href"));
    }
  } catch (Exception exception) {
  }

  return results;
}
