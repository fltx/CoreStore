//
//  MigrationResult.swift
//  CoreStore
//
//  Copyright (c) 2014 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation


// MARK: - MigrationType

/**
The `MigrationType` specifies the type of migration required for a store.
*/
public enum MigrationType: BooleanType {
    
    // MARK: Public
    
    /**
    Indicates that the persistent store matches the latest model version and no migration is needed
    */
    case None(version: String)
    
    /**
    Indicates that the persistent store does not match the latest model version but Core Data can infer the mapping model, so a lightweight migration is needed
    */
    case Lightweight(sourceVersion: String, destinationVersion: String)
    
    /**
    Indicates that the persistent store does not match the latest model version and Core Data could not infer a mapping model, so a custom migration is needed
    */
    case Heavyweight(sourceVersion: String, destinationVersion: String)
    
    /**
    Returns the source model version for the migration type. If no migration is required, `sourceVersion` will be equal to the `destinationVersion`.
    */
    public var sourceVersion: String {
        
        switch self {
            
        case .None(let version):
            return version
            
        case .Lightweight(let sourceVersion, _):
            return sourceVersion
            
        case .Heavyweight(let sourceVersion, _):
            return sourceVersion
        }
    }
    
    /**
    Returns the destination model version for the migration type. If no migration is required, `destinationVersion` will be equal to the `sourceVersion`.
    */
    public var destinationVersion: String {
        
        switch self {
            
        case .None(let version):
            return version
            
        case .Lightweight(_, let destinationVersion):
            return destinationVersion
            
        case .Heavyweight(_, let destinationVersion):
            return destinationVersion
        }
    }
    
    
    // MARK: BooleanType
    
    public var boolValue: Bool {
        
        switch self {
            
        case .None:         return false
        case .Lightweight:  return true
        case .Heavyweight:  return true
        }
    }
}


// MARK: - MigrationResult

/**
The `MigrationResult` indicates the result of a migration.
The `MigrationResult` can be treated as a boolean:

    CoreStore.upgradeSQLiteStoreIfNeeded { transaction in
        // ...
        let result = transaction.commit()
        if result {
            // succeeded
        }
        else {
            // failed
        }
    }

or as an `enum`, where the resulting associated object can also be inspected:

    CoreStore.beginAsynchronous { transaction in
        // ...
        let result = transaction.commit()
        switch result {
        case .Success(let hasChanges):
            // hasChanges indicates if there were changes or not
        case .Failure(let error):
            // error is the NSError instance for the failure
        }
    }
```
*/
public enum MigrationResult {
    
    // MARK: Public
    
    /**
    `MigrationResult.Success` indicates either the migration succeeded, or there were no migrations needed. The associated value is an array of `MigrationType`s reflecting the migration steps completed.
    */
    case Success([MigrationType])
    
    /**
    `SaveResult.Failure` indicates that the migration failed. The associated object for this value is the related `NSError` instance.
    */
    case Failure(NSError)
    
    
    // MARK: Internal
    
    internal init(_ migrationTypes: [MigrationType]) {
        
        self = .Success(migrationTypes)
    }
    
    internal init(_ error: NSError) {
        
        self = .Failure(error)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode) {
        
        self.init(errorCode, userInfo: nil)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode, userInfo: [NSObject: AnyObject]?) {
        
        self.init(NSError(coreStoreErrorCode: errorCode, userInfo: userInfo))
    }
}


// MARK: - MigrationResult: BooleanType

extension MigrationResult: BooleanType {
    
    public var boolValue: Bool {
        
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }
}
