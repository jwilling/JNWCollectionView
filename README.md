## JNWCollectionView ##
`JNWCollectionView` is a modern collection view for the Mac with an extremely flexible API. Cells are dequeued and memory usage is kept at a minimum. Cells are layer-backed by default, and performance is highly optimized. 

Anyone familiar with `UICollectionView` should feel right at home with `JNWCollectionView`. Like `UICollectionView`, `JNWCollectionView` uses the concept of a layout class for determining how items should be displayed onscreen. 


![](http://jwilling.com/drop/collectionview_hero-vdDIP2yyVy.png)

The easiest way to understand what this framework can do is to just dive in with an example. Lets go.


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
[self.view addSubview:self.collectionView];
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
self.collectionView.collectionViewLayout = gridLayout;
```

Next, we can create a custom cell that inherits from `JNWCollectionViewCell`. We then need to register this class for use in dequeuing cells.

```objc
[self.collectionView registerClass:MyCustomCell.class forCellWithReuseIdentifier:@"some identifier"];
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

You now have a fully-functioning collection view. But that's just scratching the surface. What else can be done?

## Lets dive deeper ##


## What's left to do? ##


## License ##
`JNWCollectionView` is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).

In short, I made this to help out as many people as I can. If you find it helpful, let me know! You just might make my day. 😉


## Get In Touch ##
You can follow me on Twitter as [@willing](http://twitter.com/willing), email me at the email listed on my GitHub profile, or read my blog at [jwilling.com](http://www.jwilling.com).
