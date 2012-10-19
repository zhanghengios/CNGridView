##Overview
`CNGridView` is a (wanna be) replacement for NSCollectionView. It has full delegate and dataSource support with method calls just like known from [NSTableView](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSTableView_Class/Reference/Reference.html) and [UITableView](http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableView_Class/Reference/Reference.html).

The main inspiration to develop this control came fom @JustSid who wrote the [JUCollectionView](https://github.com/JustSid/JUCollectionView). But `CNGridView` was written from ground up, it uses ARC and has a bunch of properties to customize its layout and behavior.

`CNGridView` was only testet on 10.7 Lion & 10.8 Mountain Lion.


![CNGridView Example Application](https://dl.dropbox.com/u/34133216/WebImages/Github/CNGridView-Example.png)

###Usage
To use `CNGridView` the easy work is done in a few steps:

- open InterfaceBuilder and select your NIB file that should contain the grid view
- drag a `NSScrollView` to your target view, and set the class of `NSScrollView`'s content view to `CNGridView`
- connect the delegate & dataSource
- implement all required delegate/dataSource methods and fill it with appropriate content.

Now you have a fully functionable grid view.

###Missing Features
There are some features I planned to integrate - if time permits.
* Drag & Drop
* keyboard control
* custom views for grid view items
* custom views for grid view header & footer
* sections
* ...

If you have any ideas of features you are missing, or you wanna contribute this project, please let me know. Feedback is very welcome. (-:

###Documentation
The documentation of this project is auto generated using [Appledoc](http://gentlebytes.com/appledoc/) by [@gentlebytes](https://twitter.com/gentlebytes). You can find the complete reference [here](http://cngridview.cocoanaut.com/documentation/).

###License
This software is published under the MIT License. More informations you can get [here](http://cocoanaut.mit-license.org).