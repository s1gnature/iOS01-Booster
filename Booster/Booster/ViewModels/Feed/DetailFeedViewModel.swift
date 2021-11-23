//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation
import RxSwift
import RxRelay

final class DetailFeedViewModel {
    // MARK: - Properties
    let startDate: Date
    var trackingModel = BehaviorRelay<TrackingModel>(value: TrackingModel())
    var isDeletedAll = PublishSubject<Bool>()
    private let predicate: NSPredicate
    private let usecase: DetailFeedUsecase
    private let disposeBag = DisposeBag()
    private var gradientColorOffset = -1

    // MARK: - Init
    init(start date: Date) {
        startDate = date
        predicate = NSPredicate(format: "startDate = %@", startDate as NSDate)
        usecase = DetailFeedUsecase()
        fetchDetailFeedList()
    }

    // MARK: - Functions
    func milestone(at coordinate: Coordinate) -> Milestone? {
        let target = trackingModel.value.milestones.first(where: { value in
            return value.coordinate == coordinate
        })

        return target
    }

    func reset() { gradientColorOffset = -1 }

    func remove(of milestone: Milestone) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let index = self.trackingModel.value.milestones.firstIndex(of: milestone)
            else { return Disposables.create() }

            var newTrackingModel = self.trackingModel.value
            _ = newTrackingModel.milestones.remove(at: index)

            self.usecase.update(model: newTrackingModel, predicate: self.predicate)
                .subscribe(onError: { _ in
                    observer.onNext(false)
                }, onCompleted: {
                    self.trackingModel.accept(newTrackingModel)
                    observer.onNext(true)
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func removeAll() {
        usecase.remove(predicate: predicate)
            .subscribe(onError: { _ in
                self.isDeletedAll.onNext(false)
            }, onCompleted: {
                self.isDeletedAll.onNext(true)
            })
            .disposed(by: disposeBag)
    }

    func indexOfCoordinate(_ coordinate: Coordinate) -> Int? {
        guard let currentLatitude = coordinate.latitude,
              let currentLongitude = coordinate.longitude
        else { return nil }

        for (index, compareCoordinate) in trackingModel.value.coordinates.enumerated() {
            if let latitude = compareCoordinate.latitude,
               let longitude = compareCoordinate.longitude {
                if isOnPathAsApproximation(currentLatitude: currentLatitude,
                                           currentLongitude: currentLongitude,
                                           compareLatitude: latitude,
                                           compareLongitude: longitude) { return index }
            }
        }
        return nil
    }

    func offsetOfGradientColor() -> Int {
        gradientColorOffset += 1
        return gradientColorOffset
    }

    private func isOnPathAsApproximation(currentLatitude: Double,
                                         currentLongitude: Double,
                                         compareLatitude: Double,
                                         compareLongitude: Double) -> Bool {
        let approximation = 0.00000000001
        return abs(currentLatitude - compareLatitude) < approximation && abs(currentLongitude - compareLongitude) < approximation
    }

    private func fetchDetailFeedList() {
        usecase.fetch(predicate: predicate)
            .subscribe { [weak self] value in
                guard let model = value.element
                else { return }

                self?.trackingModel.accept(model)
            }
            .disposed(by: disposeBag)
    }
}
