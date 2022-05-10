import UIKit

import RxSwift
import RxSwiftExt

final class MapToViewController: UIViewController {
    @IBOutlet weak var magicLabel: UILabel!

    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        showButton.rx.tap.asObservable()
            .mapTo(false)
            .subscribe(onNext: { [weak self] value in
                self?.magicLabel.isHidden = value
            })
            .disposed(by: disposeBag)

        hideButton.rx.tap.asObservable()
            .mapTo(true)
            .subscribe(onNext: { [weak self] value in
                self?.magicLabel.isHidden = value
            })
            .disposed(by: disposeBag)
    }

}
