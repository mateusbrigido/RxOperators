import UIKit

import RxSwift
import RxSwiftExt

final class ScanViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let plusObservable = plusButton.rx.tap
            .mapTo(+1)

        let minusObservable = minusButton.rx.tap
            .mapTo(-1)

        Observable.merge(plusObservable, minusObservable)
            .scan(0, accumulator: +)
            .debug("My Print - Scan Observable")
            .subscribe(onNext: { [weak self] value in
                self?.countLabel.text = "\(value)"
            })
            .disposed(by: disposeBag)
    }
}
