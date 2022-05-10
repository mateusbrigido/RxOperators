import UIKit

import RxSwift
import RxSwiftExt

final class WithLatestFromViewController: UIViewController {
    @IBOutlet weak var stepLabel: UITextField!
    @IBOutlet weak var countLabel: UILabel!

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!


    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let stepObservable = stepLabel.rx.text.orEmpty

        let plusObservable = plusButton.rx.tap
            .mapTo(+1)

        let minusObservable = minusButton.rx.tap
            .mapTo(-1)

        Observable.merge(plusObservable, minusObservable)
            .withLatestFrom(stepObservable) { (signal, step) -> Int in
                guard let step = Int(step) else {
                    return 0
                }
                return step * signal
            }
            .scan(0, accumulator: +)
            .subscribe(onNext: { [weak self] value in
                self?.countLabel.text = "\(value)"
            })
            .disposed(by: disposeBag)
    }
}
