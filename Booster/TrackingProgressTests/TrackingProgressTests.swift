//
//  TrackingProgressTests.swift
//  TrackingProgressTests
//
//  Created by 김태훈 on 2021/11/14.
//

import XCTest
import CoreLocation

class TrackingProgressTests: XCTestCase {
    var trackingProgressViewModel: TrackingProgressViewModel!

    override func setUpWithError() throws {
        trackingProgressViewModel = TrackingProgressViewModel(trackingModel: TrackingModel(), user: UserInfo())
    }

    override func tearDownWithError() throws {
        trackingProgressViewModel = nil
    }

    func test좌표추가() throws {
        // given
        let coordinate = Coordinate(latitude: nil, longitude: nil)

        // when
        trackingProgressViewModel.append(coordinate: coordinate)

        // then
        XCTAssertEqual(trackingProgressViewModel.trackingModel.value.coordinates.count, 1, "좌표가 추가되지 않았습니다.")
    }

    func test마일스톤추가() throws {
        // given
        let milestone = MileStone(latitude: 0, longitude: 0, imageData: Data())

        // when
        trackingProgressViewModel.append(milestone: milestone)

        // then
        XCTAssertEqual(trackingProgressViewModel.milestones.value.count, 1, "마일스톤이 추가되지 않았습니다.")
    }

    func test좌표리스트추가() throws {
        // given
        let coordinates = [Coordinate].init(repeating: Coordinate(latitude: nil, longitude: nil), count: 3)

        // when
        trackingProgressViewModel.appends(coordinates: coordinates)

        // then
        XCTAssertEqual(trackingProgressViewModel.trackingModel.value.coordinates.count, 3, "좌표 리스트가 추가되지 않았습니다.")
    }

    func test마일스톤리스트추가() throws {
        // given
        let milestones = [MileStone].init(repeating: MileStone(latitude: 0, longitude: 0, imageData: Data()), count: 3)

        // when
        trackingProgressViewModel.appends(milestones: milestones)

        // then
        XCTAssertEqual(trackingProgressViewModel.milestones.value.count, 3, "마일스톤 리스트가 추가되지 않았습니다.")
    }

    func test트래킹중일시정지토글() throws {
        // given
        let coordinate = Coordinate(latitude: nil, longitude: nil)

        // when
        trackingProgressViewModel.append(coordinate: coordinate)
        trackingProgressViewModel.toggle()

        // then
        XCTAssertNil(trackingProgressViewModel.latestCoordinate()?.latitude, "일시중지 되지 않았습니다.")
        XCTAssertNil(trackingProgressViewModel.latestCoordinate()?.longitude, "일시중지 되지 않았습니다.")
    }

    func test동일한마일스톤객체존재() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]
        let coordinate = Coordinate(latitude: 4, longitude: 5)

        // when
        trackingProgressViewModel.appends(milestones: milestones)

        // then
        XCTAssertNotNil(trackingProgressViewModel.mileStone(at: coordinate))
    }

    func test동일한마일스톤객체존재하지않음() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]
        let coordinate = Coordinate(latitude: 9, longitude: 9)

        // when
        trackingProgressViewModel.appends(milestones: milestones)

        // then
        XCTAssertNil(trackingProgressViewModel.mileStone(at: coordinate))
    }

    func test해당위치에마일스톤존재() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]

        // when
        trackingProgressViewModel.appends(milestones: milestones)

        // then
        XCTAssertTrue(trackingProgressViewModel.isMileStoneExistAt(latitude: 4, longitude: 5))
    }

    func test해당위치에마일스톤존재하지않음() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]

        // when
        trackingProgressViewModel.appends(milestones: milestones)

        // then
        XCTAssertFalse(trackingProgressViewModel.isMileStoneExistAt(latitude: 10, longitude: 5))
    }

    func test중앙위치() throws {
        // given
        let coordinates = [
            Coordinate(latitude: 0, longitude: 0),
            Coordinate(latitude: 2, longitude: 1),
            Coordinate(latitude: 4, longitude: 4)
        ]
        let result = CLLocationCoordinate2D(latitude: 2, longitude: 2)

        // when
        trackingProgressViewModel.appends(coordinates: coordinates)
        let center = trackingProgressViewModel.centerCoordinateOfPath()

        // then
        XCTAssertEqual(result.latitude.binade, center!.latitude.binade)
        XCTAssertEqual(result.longitude.binade, center!.longitude.binade)
    }

    func test마일스톤삭제성공() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]

        // when
        trackingProgressViewModel.appends(milestones: milestones)
        let remove = trackingProgressViewModel.remove(of: milestones[1])

        // then
        XCTAssertNotNil(remove)
    }

    func test마일스톤삭제실패() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]
        let otherMilestone = MileStone(latitude: 5, longitude: 6, imageData: Data())

        // when
        trackingProgressViewModel.appends(milestones: milestones)
        let remove = trackingProgressViewModel.remove(of: otherMilestone)

        // then
        XCTAssertNil(remove)
    }

    func test기록종료() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]

        // when
        trackingProgressViewModel.appends(milestones: milestones)
        trackingProgressViewModel.recordEnd()

        // then
        XCTAssertEqual(milestones.count, trackingProgressViewModel.trackingModel.value.milestones.count)
        XCTAssert(trackingProgressViewModel.state == .end)
    }

    func test코어데이터기록저장() throws {
        // given
        let milestones = [
            MileStone(latitude: 1, longitude: 2, imageData: Data()),
            MileStone(latitude: 2, longitude: 3, imageData: Data()),
            MileStone(latitude: 4, longitude: 5, imageData: Data())
        ]
        let coordinates = [
            Coordinate(latitude: 0, longitude: 0),
            Coordinate(latitude: 2, longitude: 1),
            Coordinate(latitude: 4, longitude: 4)
        ]
        let expectation = XCTestExpectation(description: "CoreDataSaveTaskExpactation")
        var error: TrackingError?
        var count: Int = 0

        // when
        trackingProgressViewModel.appends(milestones: milestones)
        trackingProgressViewModel.appends(coordinates: coordinates)
        trackingProgressViewModel.recordEnd()

        trackingProgressViewModel.save { value in
            count += 1
            if let value = value, value != TrackingError.countError {
                error = value
            }

            if count == 4 { expectation.fulfill() }
        }

        // then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(error)
    }
}
