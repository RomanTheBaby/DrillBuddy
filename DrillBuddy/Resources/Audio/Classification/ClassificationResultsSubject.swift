//
//  ClassificationResultsSubject.swift
//  DrillBuddy
//
//  Created by Roman on 2023-09-16.
//

import Combine
import Foundation
import SoundAnalysis

/// An observer that forwards Sound Analysis results to a combine subject.
///
/// Sound Analysis emits classification outcomes to observer objects. When classification completes, an
/// observer receives termination messages that indicate the reason. A subscriber receives a stream of
/// results and a termination message with an error, if necessary.
class ClassificationResultsSubject: NSObject, SNResultsObserving {
    private let subject: PassthroughSubject<SNClassificationResult, Error>

    init(subject: PassthroughSubject<SNClassificationResult, Error>) {
        self.subject = subject
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        // TODO: log firebase event
        subject.send(completion: .failure(error))
    }

    func requestDidComplete(_ request: SNRequest) {
        subject.send(completion: .finished)
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        if let result = result as? SNClassificationResult {
            subject.send(result)
        }
    }
}
