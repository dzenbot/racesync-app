//
//  CourseApi.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-26.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Interface
public protocol CourseApiInterface {

    /**
     */
    func getCourse(with courseId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Course>)

    /**
     */
    func searchCourse(with name: String, _ completion: @escaping ObjectCompletionBlock<Course>)

    /**
     */
    func getCourses(forChapter chapterId: ObjectId, currentPage: Int, pageSize: Int, _ completion: @escaping ObjectCompletionBlock<[Course]>)

    /**
     */
    func createCourse(forChapter chapterId: ObjectId, with parameters: Parameters, _ completion: @escaping ObjectCompletionBlock<Course>)

    /**
     */
    func deleteCourse(with courseId: ObjectId, _ completion: @escaping StatusCompletionBlock)
}

public class CourseApi: CourseApiInterface {

    public init() {}
    fileprivate let repositoryAdapter = RepositoryAdapter()

    public func getCourse(with courseId: ObjectId, _ completion: @escaping ObjectCompletionBlock<Course>) {

        let endpoint = EndPoint.courseSearch
        let params: Parameters = [ParamKey.id: courseId]

        repositoryAdapter.getObject(endpoint, parameters: params, type: Course.self, completion)
    }

    public func searchCourse(with name: String, _ completion: @escaping ObjectCompletionBlock<Course>) {

        let endpoint = EndPoint.courseSearch
        let params: Parameters = [ParamKey.name: name]

        repositoryAdapter.getObject(endpoint, parameters: params, type: Course.self, completion)
    }

    public func getCourses(forChapter chapterId: ObjectId, currentPage: Int = 0, pageSize: Int = StandardPageSize, _ completion: @escaping ObjectCompletionBlock<[Course]>) {

        let endpoint = EndPoint.courseList
        let params: Parameters = [ParamKey.chapterId: chapterId]

        repositoryAdapter.getObjects(endpoint, parameters: params, currentPage: currentPage, pageSize: pageSize, type: Course.self, completion)
    }

    public func createCourse(forChapter chapterId: ObjectId, with parameters: Parameters, _ completion: @escaping ObjectCompletionBlock<Course>) {

        let endpoint = "\(EndPoint.courseCreate)?\(ParamKey.chapterId)=\(chapterId)"

        repositoryAdapter.getObject(endpoint, parameters: parameters, type: Course.self, completion)
    }

    public func deleteCourse(with courseId: ObjectId, _ completion: @escaping StatusCompletionBlock) {

        let endpoint = EndPoint.courseDelete
        let params: Parameters = [ParamKey.id: courseId]

        repositoryAdapter.performAction(endpoint, parameters: params, completion: completion)
    }
}

fileprivate extension CourseApi {

}
