module searchfor.content;

private const defaultUserAgent = "Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0";

string getPageContent(string url, string userAgent = defaultUserAgent) {
  try {
    import std.string : strip;

    import arsd.dom : Document;
    import arsd.http2 : HttpClient, Uri, HttpVerb;

    auto client = new HttpClient();
    client.userAgent = userAgent;

    auto request = client.navigateTo(Uri(url), HttpVerb.GET);
    auto response = request.waitForCompletion();

    auto document = new Document();
    document.parseGarbage(cast(string) response.content);

    foreach (selector; ["[role=\"main\"]", "main", "#main", "#content", "body"]) {
      auto element = document.querySelector(selector);
      if (element is null) {
        continue;
      }

      auto elementContent = element.innerText.strip;
      if (elementContent.length > 0) {
        return cleanContent(elementContent);
      }
    }
  } catch (Exception exception) {
  }

  return "";
}

private string cleanContent(string content) {
  import std.regex : regex, replaceAll, match;

  const reduceNewLinePattern = regex(r"\n\s+\n", "g");
  const requiresJavaScriptPattern = regex(r"(requires?|enable)\s+JavaScript", "gi");

  const cleaned = content.replaceAll(reduceNewLinePattern, "\n\n");

  if (cleaned.match(requiresJavaScriptPattern)) {
    return "";
  }

  return cleaned;
}
