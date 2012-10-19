##Overview
`CNGridView` is a (wanna be) replacement for NSCollectionView. It has full delegate and dataSource support with method calls just like known from [NSTableView](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSTableView_Class/Reference/Reference.html) and [UITableView](http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableView_Class/Reference/Reference.html).

![CNGridView Example Application](https://dl.dropbox.com/u/34133216/WebImages/Github/CNGridView-Example.png)

###Usage
To use `CNGridView` the easy work is done in a few steps:

- open InterfaceBuilder and select your NIB file that should contain the grid view
- Drag a `NSScrollView` to your target view, and set the class of `NSScrollView`'s content view to `CNGridView`

![Xcode Objects Browser](https://dl.dropbox.com/u/34133216/WebImages/Github/XcodeObjectsBrowser.png)
![Xcode Inspector](https://dl.dropbox.com/u/34133216/WebImages/Github/XcodeInspector.png)

- connect the delegate & dataSource
- implement all required delegate/dataSource methods

With this setting you will get all the default settings. `CNGridView`

###Documentation
The documentation of this project is auto generated using [Appledoc](http://gentlebytes.com/appledoc/) by [@gentlebytes](https://twitter.com/gentlebytes). You can find the complete reference [here](http://cngridview.cocoanaut.com/documentation/).

###License
This software is published under the MIT License. More informations you can get [here](http://cocoanaut.mit-license.org).