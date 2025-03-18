//
//  CoreDataManager.swift
//  MovieApps
//
//  Created by Faza Azizi on 19/03/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieApps")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func saveMovies(_ movies: [Movie]) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            
            for movie in movies {
                let movieEntity = MovieEntity(context: viewContext)
                movieEntity.id = Int64(movie.id)
                movieEntity.title = movie.title
                movieEntity.overview = movie.overview
                movieEntity.posterPath = movie.posterPath
                movieEntity.voteAverage = movie.voteAverage
                movieEntity.releaseDate = movie.releaseDate
            }
            
            saveContext()
        } catch {
            print("Error saving movies to Core Data: \(error)")
        }
    }
    
    func fetchMovies() -> [Movie] {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let movieEntities = try viewContext.fetch(fetchRequest)
            return movieEntities.map { entity in
                Movie(
                    id: Int(entity.id),
                    title: entity.title ?? "",
                    overview: entity.overview ?? "",
                    posterPath: entity.posterPath,
                    releaseDate: entity.releaseDate,
                    voteAverage: entity.voteAverage
                )
            }
        } catch {
            print("Error fetching movies from Core Data: \(error)")
            return []
        }
    }
    
    func isDataSaved(word: String) -> Bool {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", word)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Error checking if data exists: \(error)")
            return false
        }
    }
}
