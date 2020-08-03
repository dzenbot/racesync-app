//
//  CompletionBlock.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public typealias VoidCompletionBlock = () -> Void
public typealias CompletionBlock = (_ error: NSError?) -> Void
public typealias StatusCompletionBlock = (_ status: Bool, _ error: NSError?) -> Void
public typealias ObjectCompletionBlock<T> = (_ object: T?, _ error: NSError?) -> Void
public typealias SimpleObjectCompletionBlock<T> = (_ object: T) -> Void
public typealias ProgressBlock = (_ fractionCompleted: Float) -> Void
