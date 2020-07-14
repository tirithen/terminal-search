module searchfor.cache;

private string getCacheDirectory() {
  import std.path : expandTilde;

  return "~/.cache/search".expandTilde;
}

void cacheClear() {
  const directory = getCacheDirectory();

  try {
    import std.file : rmdirRecurse;

    rmdirRecurse(directory);
  } catch (Exception exception) {
  }
}

void cacheWrite(T)(string key, T data) {
  import std.file : write, mkdirRecurse;
  import std.digest : toHexString;
  import std.conv : to;
  import msgpack : pack;

  const directory = getCacheDirectory();
  mkdirRecurse(directory);

  const filename = directory ~ "/" ~ (cast(ubyte[]) key).toHexString;
  write(filename, pack(data));
}

import std.typecons : Nullable;
import core.time : Duration;

Nullable!T cacheRead(T)(string key, Duration maxAge = Duration.max) {
  import std.file : read, timeLastModified;
  import std.digest : toHexString;
  import std.conv : to;
  import std.datetime.systime : Clock;
  import msgpack : unpack;

  const directory = getCacheDirectory();
  const filename = directory ~ "/" ~ (cast(ubyte[]) key).toHexString;

  Nullable!T nil;

  try {
    const modified = timeLastModified(filename);
    const today = Clock.currTime();
    if (today - modified > maxAge) {
      return nil;
    }

    ubyte[] data = cast(ubyte[]) read(filename);
    T cached = data.unpack!T();

    return cast(Nullable!T) cached;
  } catch (Exception exception) {
  }

  return nil;
}
