import UIKit

import RxSwift
import RxCocoa

enum AnimalType: Int {
    case dog = 0
    case cat = 1
}

final class CombineLatestViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var petTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var suggestionsTableView: UITableView!


    private let catBreedService = CatBreedService()
    private let dogBreedService = DogBreedService()
    private let disposeBag = DisposeBag()
    private var suggestions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let queryObservable = searchTextField.rx.text.orEmpty
            .map { $0.lowercased() }

        let animalTypeObservable = petTypeSegmentedControl.rx.selectedSegmentIndex
            .compactMap { AnimalType(rawValue: $0) }

        Observable.combineLatest(queryObservable, animalTypeObservable)
            .enumerated()
            .map { index, element in
                (index, element.0, element.1)
            }
            .flatMap { [weak self] index, query, type -> Observable<(Int, [String])> in
                guard let self = self else { return .empty() }

                switch type {
                case .dog:
                    return self.dogBreedService.getBreeds(for: query)
                        .map { (index, $0) }
                case .cat:
                    return self.catBreedService.getBreeds(for: query)
                        .map { (index, $0) }
                }
            }
            .scan((0, [String]()), accumulator: { lastEvent, nextEvent in
                nextEvent.0 < lastEvent.0 ? lastEvent : nextEvent
            })
            .map { $0.1 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] suggestions in
                self?.suggestions = suggestions
                self?.suggestionsTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension CombineLatestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)

        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
}

private final class CatBreedService {
    static var requestCount = 0
//    static let delays = [30000, 20000, 10000, 7500, 5000, 2000, 1500, 1000, 700, 500]
    static let delays = [500]

    func getBreeds(for query: String) -> Observable<[String]> {
        let delay = getDelay()
        return Observable.create { observer in
            let suggestions = Self.words.filter { $0.lowercased().starts(with: query) }
            observer.onNext(suggestions)

            return Disposables.create()
        }
        .delay(.milliseconds(delay), scheduler: MainScheduler.instance)
    }

    private func getDelay() -> Int {

        guard Self.requestCount < Self.delays.count else {
            return Self.delays.last!
        }
        let delay = Self.delays[Self.requestCount]
        Self.requestCount += 1
        return delay
    }

    private static var words = [
        "Abyssinian", "Aegean", "American Bobtail", "American Curl", "American Shorthair", "American Wirehair", "Aphrodite Giant", "Arabian Mau", "Asian", "Australian Mist", "Balinese", "Bambino", "Bengal Cats", "Birman", "Bombay", "Brazilian Shorthair", "British Longhair", "British Shorthair", "Burmese", "Burmilla", "California Spangled", "Chantilly-Tiffany", "Chartreux", "Chausie", "Chinese Li Hua", "Colorpoint Shorthair", "Cornish Rex", "Cymric", "Cyprus", "Desert Lynx", "Devon Rex", "Donskoy", "Egyptian Mau", "European Burmese", "European Shorthair", "Exotic", "Foldex", "German Rex", "Havana Brown", "Highlander", "Himalayan", "Japanese Bobtail", "Javanese", "Khao Manee", "Korat", "Kurilian Bobtail", "LaPerm", "Lykoi", "Maine Coon", "Manx", "Mekong Bobtail", "Napoleon", "Nebelung", "Norwegian Forest", "Ocicat", "Oriental Bicolor", "Oriental", "Persian", "Peterbald", "Pixie-Bob", "Ragamuffin", "Ragdoll Cats", "Russian Blue", "Savannah", "Scottish Fold", "Selkirk Rex", "Serengeti", "Siamese Cat", "Siberian", "Singapura", "Snowshoe", "Sokoke", "Somali", "Sphynx", "Thai", "Thai Lilac", "Tonkinese", "Toyger", "Turkish Angora", "Turkish Van", "Ukrainian Levkoy", "York Chocolate"
    ]
}

private final class DogBreedService {
    static var requestCount = 0
    static let delays = [500]

    func getBreeds(for query: String) -> Observable<[String]> {
        let delay = getDelay()
        return Observable.create { observer in
            let suggestions = Self.words.filter { $0.lowercased().starts(with: query) }
            observer.onNext(suggestions)

            return Disposables.create()
        }
        .delay(.milliseconds(delay), scheduler: MainScheduler.instance)
    }

    private func getDelay() -> Int {

        guard Self.requestCount < Self.delays.count else {
            return Self.delays.last!
        }
        let delay = Self.delays[Self.requestCount]
        Self.requestCount += 1
        return delay
    }

    private static var words = [
        "Afador", "Affenhuahua", "Affenpinscher", "Afghan Hound", "Airedale Terrier", "Akbash", "Akita", "Akita Chow", "Akita Pit", "Akita Shepherd", "Alaskan Klee Kai", "Alaskan Malamute", "American Bulldog", "American English Coonhound", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Pit Bull Terrier", "American Pugabull", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Appenzeller Sennenhunde", "Auggie", "Aussiedoodle", "Aussiepom", "Australian Cattle Dog", "Australian Kelpie", "Australian Retriever", "Australian Shepherd", "Australian Shepherd Husky", "Australian Shepherd Lab Mix", "Australian Shepherd Pit Bull Mix", "Australian Stumpy Tail Cattle Dog", "Australian Terrier", "Azawakh", "Barbet", "Basenji", "Bassador", "Basset Fauve de Bretagne", "Basset Hound", "Basset Retriever", "Bavarian Mountain Scent Hound", "Beabull", "Beagle", "Beaglier", "Bearded Collie", "Bedlington Terrier", "Belgian Laekenois", "Belgian Malinois", "Belgian Sheepdog", "Belgian Tervuren", "Bergamasco Sheepdog", "Berger Picard", "Bernedoodle", "Bernese Mountain Dog", "Bichon Frise", "Biewer Terrier", "Black and Tan Coonhound", "Black Mouth Cur", "Black Russian Terrier", "Bloodhound", "Blue Lacy", "Bluetick Coonhound", "Bocker", "Boerboel", "Boglen Terrier", "Bohemian Shepherd", "Bolognese", "Borador", "Border Collie", "Border Sheepdog", "Border Terrier", "Bordoodle", "Borzoi", "BoShih", "Bossie", "Boston Boxer", "Boston Terrier", "Boston Terrier Pekingese Mix", "Bouvier des Flandres", "Boxador", "Boxer", "Boxerdoodle", "Boxmatian", "Boxweiler", "Boykin Spaniel", "Bracco Italiano", "Braque du Bourbonnais", "Briard", "Brittany", "Broholmer", "Brussels Griffon", "Bugg", "Bull Arab", "Bull Terrier", "Bull-Pei", "Bullador", "Bullboxer Pit", "Bulldog", "Bullmastiff", "Bullmatian", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Bulldog", "Catahoula Leopard Dog", "Caucasian Shepherd Dog", "Cav-a-Jack", "Cavachon", "Cavador", "Cavalier King Charles Spaniel", "Cavapoo", "Central Asian Shepherd Dog", "Cesky Terrier", "Chabrador", "Cheagle", "Chesapeake Bay Retriever", "Chi Chi", "Chi-Poo", "Chigi", "Chihuahua", "Chilier", "Chinese Crested", "Chinese Shar-Pei", "Chinook", "Chion", "Chipin", "Chiweenie", "Chorkie", "Chow Chow", "Chow Shepherd", "Chug", "Chusky", "Cirneco dell’Etna", "Clumber Spaniel", "Cockalier", "Cockapoo", "Cocker Spaniel", "Collie", "Corgi Inu", "Corgidor", "Corman Shepherd", "Coton de Tulear", "Croatian Sheepdog", "Curly-Coated Retriever", "Dachsador", "Dachshund", "Dalmatian", "Dandie Dinmont Terrier", "Daniff", "Danish-Swedish Farmdog", "Deutscher Wachtelhund", "Doberdor", "Doberman Pinscher", "Docker", "Dogo Argentino", "Dogue de Bordeaux", "Dorgi", "Dorkie", "Doxiepoo", "Doxle", "Drentsche Patrijshond", "Drever", "Dutch Shepherd", "English Cocker Spaniel", "English Foxhound", "English Setter", "English Springer Spaniel", "English Toy Spaniel", "Entlebucher Mountain Dog", "Estrela Mountain Dog", "Eurasier", "Field Spaniel", "Fila Brasileiro", "Finnish Lapphund", "Finnish Spitz", "Flat-Coated Retriever", "Fox Terrier", "French Bulldog", "French Bullhuahua", "French Spaniel", "Frenchton", "Frengle", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shepherd Pit Bull", "German Shepherd Rottweiler Mix", "German Sheprador", "German Shorthaired Pointer", "German Spitz", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Goberian", "Goldador", "Golden Cocker Retriever", "Golden Mountain Dog", "Golden Retriever", "Golden Retriever Corgi", "Golden Shepherd", "Goldendoodle", "Gollie", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyador", "Greyhound", "Hamiltonstovare", "Hanoverian Scenthound", "Harrier", "Havanese", "Havapoo", "Hokkaido", "Horgi", "Hovawart", "Huskita", "Huskydoodle", "Ibizan Hound", "Icelandic Sheepdog", "Irish Red And White Setter", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jack Chi", "Jack Russell Terrier", "Jack-A-Poo", "Jackshund", "Japanese Chin", "Japanese Spitz", "Kai Ken", "Karelian Bear Dog", "Keeshond", "Kerry Blue Terrier", "King Shepherd", "Kishu Ken", "Komondor", "Kooikerhondje", "Korean Jindo Dog", "Kuvasz", "Kyi-Leo", "Lab Pointer", "Labernese", "Labmaraner", "Labrabull", "Labradane", "Labradoodle", "Labrador Retriever", "Labrastaff", "Labsky", "Lagotto Romagnolo", "Lakeland Terrier", "Lancashire Heeler", "Leonberger", "Lhasa Apso", "Lhasapoo", "Lowchen", "Maltese", "Maltese Shih Tzu", "Maltipoo", "Manchester Terrier", "Maremma Sheepdog", "Mastador", "Mastiff", "Miniature Pinscher", "Miniature Schnauzer", "Morkie", "Mountain Cur", "Mountain Feist", "Mudi", "Mutt (Mixed)", "Neapolitan Mastiff", "Newfoundland", "Norfolk Terrier", "Northern Inuit Dog", "Norwegian Buhund", "Norwegian Elkhound", "Norwegian Lundehund", "Norwich Terrier", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Otterhound", "Papillon", "Papipoo", "Patterdale Terrier", "Peekapoo", "Pekingese", "Pembroke Welsh Corgi", "Petit Basset Griffon Vendéen", "Pharaoh Hound", "Pitsky", "Plott", "Pocket Beagle", "Pointer", "Polish Lowland Sheepdog", "Pomapoo", "Pomchi", "Pomeagle", "Pomeranian", "Pomsky", "Poochon", "Poodle", "Portuguese Podengo Pequeno", "Portuguese Pointer", "Portuguese Sheepdog", "Portuguese Water Dog", "Pudelpointer", "Pug", "Pugalier", "Puggle", "Puginese", "Puli", "Pyredoodle", "Pyrenean Mastiff", "Pyrenean Shepherd", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottador", "Rottle", "Rottweiler", "Saint Berdoodle", "Saint Bernard", "Saluki", "Samoyed", "Samusky", "Schipperke", "Schnoodle", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Sheepadoodle", "Shepsky", "Shetland Sheepdog", "Shiba Inu", "Shichon", "Shih Tzu", "Shih-Poo", "Shikoku", "Shiloh Shepherd", "Shiranian", "Shollie", "Shorkie", "Siberian Husky", "Silken Windhound", "Silky Terrier", "Skye Terrier", "Sloughi", "Small Munsterlander Pointer", "Soft Coated Wheaten Terrier", "Spanish Mastiff", "Spinone Italiano", "Springador", "Stabyhoun", "Staffordshire Bull Terrier", "Staffy Bull Bullmastiff", "Standard Schnauzer", "Sussex Spaniel", "Swedish Lapphund", "Swedish Vallhund", "Taiwan Dog", "Terripoo", "Texas Heeler", "Thai Ridgeback", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Transylvanian Hound", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Valley Bulldog", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Westiepoo", "Whippet", "Whoodle", "Wirehaired Pointing Griffon", "Xoloitzcuintli", "Yakutian Laika", "Yorkipoo", "Yorkshire Terrier"
    ]
}
