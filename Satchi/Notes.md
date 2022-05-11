#  General notes about the development

## Clip from SO:
https://stackoverflow.com/questions/66773027/implementing-sharing-with-nspersistentcloudkitcontainer-in-swiftui

```
The Apple engineer's answer in the forum reads quite clearly to me:

NSPersistantCloudKitContainer does not support sharing!
You need to implement CloudKit sharing through CK APIs.
I have not implemented such a feature yet, but I would approach it like this:

Get the NSPersistantCloudKitContainer implementation working.
Implement CloudKit sharing on the same container.
Start passing specific records from NSPersistantCloudKitContainer into the sharing feature implemented in step 2.
To access the shared Cloudkit database with CKDatabase.Scope = shared:

If this is the NSPersistentCloudKitContainer:
container = NSPersistentCloudKitContainer(name: "AppName") 
I would try to access the shared DB of this container like so:

let myAppsCloudKitContainer = CKContainer(identifier: "iCloud.com.name.AppName")
let myContainersSharedDatabase = myAppsCloudKitContainer.database(with: .shared)
To access data from NSPersistantCloudKitContainer for use in the CloudKit sharing feature 
use NSPersistantCloudKitContainer instance method record(for managedObjectID: NSManagedObjectID)

--
It actually does support sharing: developer.apple.com/videos/play/wwdc2021/10015 though I 
dont think anyone has got it working yet. The doc in typical apple coredata/cloudkit fashion 
was out of date even when they presented it at WWDC 2021 (it still uses AppDelegate for example) and doesn't seem to work. – 

```

## TODO:
- Rewrite the slide for difficulty in EditView. Maybe something like this https://medium.com/@alessandromanilii/animated-rating-view-in-swiftui-9b2f00e8196d .
- Add sharing
- Add logging
- Fix long names in edit view. To long name looks realy bad...
- Make time since... look better in edit view. Might contain years etc...


