![](http://appjon.com/drop/github/jnwcollectionview/title.png)

`JNWCollectionView` is a modern collection view for the Mac with an extremely flexible API. Cells are dequeued and memory usage is kept at a minimum. The collection view is layer-backed by default, and performance is highly optimized.

Anyone familiar with `UICollectionView` should feel right at home with `JNWCollectionView`. Like `UICollectionView`, `JNWCollectionView` uses the concept of a layout class for determining how items should be displayed onscreen. 

The easiest way to understand what this framework can do is to just dive in with an example. Lets go.

*If you just want to know how to download the project, see [below](README.md#how-do-i-add-it-to-my-project).*

## Compatibility ##

`JNWCollectionView` requires OS X 10.8+.

## Getting Started ##

`JNWCollectionView` inherits from `NSScrollView`, so it can either be instantiated through code or in Interface Builder. The following example demonstrates creating a collection view through code.


First, make sure you're linking with the `JNWCollectionView` framework and have imported the header.
```objc
#import <JNWCollectionView/JNWCollectionView.h>
```


```objc
// Create the collection view
JNWCollectionView *collectionView = [[JNWCollectionView alloc] initWithFrame:self.view.bounds];
collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
[self.view addSubview:collectionView];
```

As with UI/NSTable/CollectionView, the data source is required. Make sure the class conforms to `JNWCollectionViewDataSource`.

```objc
@interface SomeViewController : NSViewController <JNWCollectionViewDataSource>
```

Then the class can set itself as the data source.

```objc
collectionView.dataSource = self;
```

`JNWCollectionView` does not automatically pick a layout class. Two layout classes are included (and will be described later). For this example, lets pick the grid layout. However, the layout class is designed to be subclassed so you are not limited to the built-in layouts.

```objc
JNWCollectionViewGridLayout *gridLayout = [[JNWCollectionViewGridLayout alloc] initWithCollectionView:collectionView];

// The grid layout has its own delegate, so if we want to implement the delegate methods
// we need to conform to JNWCollectionViewGridLayoutDelegate.
gridLayout.delegate = self; 

// Tell the grid layout the size of our cells.
gridLayout.itemSize = CGSizeMake(100, 100);

// Set the grid layout as the collection view layout, or the layout
// that is used for positioning the items in the collection view.
collectionView.collectionViewLayout = gridLayout;
```

Next, we can create a custom cell that inherits from `JNWCollectionViewCell`. We then need to register this class for use in dequeuing cells.

```objc
[collectionView registerClass:MyCustomCell.class forCellWithReuseIdentifier:@"some identifier"];
```

Almost done. Lets implement the required data source methods.

```objc
- (JNWCollectionViewCell *)collectionView:(JNWCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MyCustomCell *cell = (MyCustomCell *)[collectionView dequeueReusableCellWithIdentifier:@"some identifier"];
	// customize cell here
	return cell;
}

- (NSUInteger)collectionView:(JNWCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 200;
}
```

That's it. Lets call the initial reload.

```objc
[collectionView reloadData];
```

You now have a fully-functioning collection view. But that's just scratching the surface. **Take a look at the demo project and give it a spin**, otherwise keep reading.

## Lets dive deeper ##

### What makes this better than NSCollectionView / NSTableView? ###

`NSCollectionView` is sadly neglected. `NSCollectionView` does not attempt to reuse cells at all, meaning it will every single cell, even if it's not onscreen. It cannot handle being layer-backed, and therefore scrolling performance is terrible. It is not very customizable.

`NSTableView` is (still) a well designed class, however it is not perfect. For example, in newer versions of OS X, it forces Auto Layout to be enabled. It is not very easy to customize, and its support for legacy brings a lot of baggage along with the current API. Although scrolling performance is quite good, it can be improved upon.

On the contrary, `JNWCollectionView` was designed from the ground up to be as fast and as lightweight as possible, using a combination of layer-backed views and optimized cell dequeuing, refined by relentless profiling and tweaking. Although scrolling performance could probably be improved even more, `JNWCollectionView` is reaching the bounds of what is possible using pure AppKit. There is no legacy baggage — this was built from the ground up for speed and ease of use.


### Layouts ###

![](http://appjon.com/drop/github/jnwcollectionview/layouts.png)

As mentioned in the introduction, `JNWCollectionView` is completely based around the concept of layouts. A collection view can only have a single layout at one time. The layout is responsible for determining where items should be positioned, however *it does not touch the view layer itself*. The distinction is made between "items" and "cells", where items stand for the data representation of views themselves, such as the frame, the alpha value, the index path, etc. The cell itself is the view.

`JNWCollectionViewLayout` subclasses, then, are responsible for determining how to lay out the *items* in the collection view, in addition to supplementary views. The collection view itself handles the views. 

The layout is also responsible for handling certain aspects of selection. Selection can be triggered by the mouse *and* the keyboard. `JNWCollectionView` has a helper API that attempts to make handling selection events as easy as possible.

So, to accomplish anything powerful with `JNWCollectionView`, a layout subclass must be used. Two are included (list and grid), however there are many more layouts that can be created if desired. For examples of how to subclass `JNWCollectionViewLayout`, see `JNWCollectionViewListLayout` and `JNWCollectionViewGridLayout`. The header contains full documentation and subclassing advice.

### Cells ###
Cells are built on top of the `JNWCollectionViewCell` class. There are multiple convenience methods available for use.

Every `JNWCollectionViewCell` instance has two subviews by default. One is the background view, which cannot be modified directly. Instead, it can be customized by setting either an image or a color using the related properties (`backgroundImage` and `backgroundColor`).

The other subview is the `contentView`. Any subviews added to the cell should be added to this view to guarantee correct ordering with the background view.

There are many more methods and details available for discovery in the header.

### Supplementary Views ###

Supplementary views are reusable views that are distinguished by the use of identifiers, know as "kinds". There can only be one supplementary view for each *kind* in a single section. This does not mean you are limited to a single supplementary view in each section. Instead, if multiple supplementary views are needed, they should be registered under a separate kind.

All supplementary views are built on top of `JNWCollectionViewReusableView`. See the header for more details.

### The Collection View ###

Take a look [at the header itself](https://github.com/jwilling/jnwcollectionview/blob/master/JNWCollectionView/JNWCollectionViewFramework.h), as the documentation is thorough.

## How do I add it to my project? ##

`JNWCollectionView` has external dependencies. When you clone the project, make sure you clone the project recursively to pull down the submodules.

    git clone --recursive https://github.com/jwilling/JNWCollectionView.git
    
One you have the framework pulled, the next step is to link the framework with your app. The easiest way to do this is to add `JNWCollectionView` as a subproject of your project as a target dependency. If you're confused, the demo application demonstrates the correct way to link to the framework.

## Case Study ##

![](http://appjon.com/drop/github/jnwcollectionview/custom-layout-wwdc.png)

This is an app I wrote for Apple's WWDC'13 scholarship. It was mostly written to demonstrate what my collection view could do, so I have decided to release the source for it, most of which was written in a day. It demonstrates a custom layout class that creates a timeline arrangement. The line is composed of supplementary views, and the text, images, and selection dot are all cells. Each row across the screen is a section. If the demo in this repo is underwhelming in complexity, take this app for a spin and check out the layout class. It can be found [here](https://github.com/jwilling/WWDC--13-Scholarship-App).

## What's left to do? ##

- Flow layout.
- Animated insertion / removals
- Batch reloads
- Drag and drop

## License ##
`JNWCollectionView` is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).

In short, I made this to help out as many people as I can. If you find it helpful, let me know! You just might make my day. :wink:

## Get In Touch ##
You can follow me on Twitter as [@willing](http://twitter.com/willing), email me at the email listed on my GitHub profile, or read my blog at [jwilling.com](http://www.jwilling.com). If you have questions, feel free to post an issue here on GitHub, or just ping me on Twitter.
