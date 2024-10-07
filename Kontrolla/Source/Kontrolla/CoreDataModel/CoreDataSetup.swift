import CoreData

// In your Persistence Controller
let container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "SvenskBokforingAI")
    let url = container.persistentStoreDescriptions.first?.url
    let description = NSPersistentStoreDescription(url: url!)
    description.setOption(true as NSNumber, forKey: NSPersistentStoreFileProtectionKey)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Unresolved error \(error)")
        }
    }
    return container
}()