import UIKit

import RxSwift
import RxSwiftExt

final class MergeViewController: UIViewController {
    @IBOutlet weak var magicLabel: UILabel!

    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let showObservable = showButton.rx.tap
            .mapTo(false)

        let hideObservable = hideButton.rx.tap
            .mapTo(true)

        Observable.merge(showObservable, hideObservable)
            .subscribe(onNext: { [weak self] value in
                self?.magicLabel.isHidden = value
            })
            .disposed(by: disposeBag)
    }
}
