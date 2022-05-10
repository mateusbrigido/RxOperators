import UIKit

import RxSwift
import RxSwiftExt

final class MapViewController: UIViewController {
    @IBOutlet weak var stepLabel: UITextField!
    @IBOutlet weak var countLabel: UILabel!

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let stepObservable = stepLabel.rx.text.orEmpty

        let plusObservable = plusButton.rx.tap
            .withLatestFrom(stepObservable)
            .map { Int($0) ?? 0 }

        let minusObservable = minusButton.rx.tap
            .withLatestFrom(stepObservable)
            .map { -(Int($0) ?? 0) }

        Observable.merge(plusObservable, minusObservable)
            .scan(0, accumulator: +)
            .subscribe(onNext: { [weak self] value in
                self?.countLabel.text = "\(value)"
            })
            .disposed(by: disposeBag)
    }
}
