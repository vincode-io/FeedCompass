![Feed Compass Icon](images/Feed-Compass-Banner.png)

# 

Feed Compass is a macOS application that makes it easier to find and subscribe
to RSS Feeds in your favorite RSS Reader.  It is a companion app to an RSS
Reader so you will want one of those to get the most from Feed Compass.

There are lots of Mac RSS Readers available in the Mac App Store.  If you are
looking for a good, free RSS Reader we recommend 
[NetNewsWire](https://ranchero.com/netnewswire/).

## Features

- A large number of default feeds (especially Apple developer feeds)
- Preview feeds before you subscribe
- One click subscribing to native RSS readers or web RSS readers
- Drag-and-drop feeds to native RSS readers (that support it)
- Open local OPML files
- Subscribe to OPML files found on the web

## Feedback

Have something you want to say about Feed Compass?  Leave a comment in our
[Feedback](https://github.com/vincode-io/FeedCompass/issues/17) issue.

## Contributing

Pull requests are welcome.  If you are a non-technical person and want to
contribute you can file bug reports and feature requests on the 
[Issues](https://github.com/vincode-io/FeedCompass/issues) page.

If you have an OPML file that you think should be included in the default
feeds, please file an [Issue](https://github.com/vincode-io/FeedCompass/issues)
for it.

## Building

From the command line run the following commands:
```
git clone https://github.com/vincode-io/FeedCompass.git
cd FeedCompass
git submodule init
git submodule update
```

You can now open the Feed Compass.xcodeproj project.  You will have to fix
the project signing before building and running.

## Licence

MIT Licensed

## Credits

Many thanks to [Brent Simmons](http://inessential.com) for the coming up with
the idea for this program.  We would also like to thank him for open sourcing
the many libraries of his we use.

We would also like to thank the creators of the OPML files utilized by Feed
Compass.  This program would be nothing without their work curating the OMPL
blog listings.
