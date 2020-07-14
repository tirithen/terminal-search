# search

[![DUB Package](https://img.shields.io/dub/v/search.svg)](https://code.dlang.org/packages/search)

Search the web from the terminal.

![Demonstration of the search command](demo.gif)

You can choose to search with either duckduckgo (default) or google with the `--engine` option.

So far the command is only tested for Linux systems, feel free to contribute/suggest other platforms.

## Usage

    $ search my search query

It's often helpful to pipe the search thorugh less:

    $ search my search query | less

For more details run:

    $ search --help

## Build

Use ldc2 to create a smaller and faster binary.

    $ dub build --compiler=ldc2 --build=release

Place the binary file in a PATH directory.
