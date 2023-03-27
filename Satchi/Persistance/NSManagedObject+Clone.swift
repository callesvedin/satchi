
// This code is stolen/based on a copy from this Stackoverflow posting https://stackoverflow.com/a/66966869
// by Alexander Braekevelt (https://stackoverflow.com/users/5504977/alexander-braekevelt)
// It takes care of creating a deep copy of an NSManaged Object.
// Used in this project to copy objects being unshared.
import CoreData

extension NSManagedObject {
    enum DeepCopyError: Error {
        case missingContext
        case missingEntityName(NSManagedObject)
        case unmanagedObject(Any)
    }

    func deepcopy(context: NSManagedObjectContext? = nil) throws -> NSManagedObject {
        if let context = context ?? managedObjectContext {
            var cache = [NSManagedObjectID: NSManagedObject]()
            return try deepcopy(context: context, cache: &cache)

        } else {
            throw DeepCopyError.missingContext
        }
    }

    private func deepcopy(context: NSManagedObjectContext, cache alreadyCopied: inout [NSManagedObjectID: NSManagedObject]) throws -> NSManagedObject {
        guard let entityName = entity.name else {
            throw DeepCopyError.missingEntityName(self)
        }

        if let storedCopy = alreadyCopied[objectID] {
            return storedCopy
        }

        let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        alreadyCopied[objectID] = cloned

        // Loop through all attributes and assign then to the clone
        NSEntityDescription
            .entity(forEntityName: entityName, in: context)?
            .attributesByName
            .forEach { attribute in
                cloned.setValue(value(forKey: attribute.key), forKey: attribute.key)
            }

        // Loop through all relationships, and clone them.
        try NSEntityDescription
            .entity(forEntityName: entityName, in: context)?
            .relationshipsByName
            .forEach { relation in

                if relation.value.isToMany {
                    if relation.value.isOrdered {
                        // Get a set of all objects in the relationship
                        let sourceSet = mutableOrderedSetValue(forKey: relation.key)
                        let clonedSet = cloned.mutableOrderedSetValue(forKey: relation.key)

                        for object in sourceSet.objectEnumerator() {
                            if let relatedObject = object as? NSManagedObject {
                                // Clone it, and add clone to the set
                                let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                                clonedSet.add(clonedRelatedObject as Any)

                            } else {
                                throw DeepCopyError.unmanagedObject(object)
                            }
                        }

                    } else {
                        // Get a set of all objects in the relationship
                        let sourceSet = mutableSetValue(forKey: relation.key)
                        let clonedSet = cloned.mutableSetValue(forKey: relation.key)

                        for object in sourceSet.objectEnumerator() {
                            if let relatedObject = object as? NSManagedObject {
                                // Clone it, and add clone to the set
                                let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                                clonedSet.add(clonedRelatedObject as Any)

                            } else {
                                throw DeepCopyError.unmanagedObject(object)
                            }
                        }
                    }

                } else if let relatedObject = self.value(forKey: relation.key) as? NSManagedObject {
                    // Clone it, and assign then to the clone
                    let clonedRelatedObject = try relatedObject.deepcopy(context: context, cache: &alreadyCopied)
                    cloned.setValue(clonedRelatedObject, forKey: relation.key)
                }
            }

        return cloned
    }
}
