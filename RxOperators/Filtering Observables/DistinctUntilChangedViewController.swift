import UIKit

import RxSwift
import RxCocoa

final class DistinctUntilChangedViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var suggestionsTableView: UITableView!

    private let autocompleteService = AutocompleteService()
    private let disposeBag = DisposeBag()
    private var suggestions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.rx.text.orEmpty
            .map { $0.lowercased() }
            .flatMap { [weak self] query -> Observable<[String]> in
                guard let self = self else { return .empty() }
                return self.autocompleteService.autocompleteSuggestions(for: query)
            }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] suggestions in
                self?.suggestions = suggestions
                self?.suggestionsTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension DistinctUntilChangedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)

        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
}

private final class AutocompleteService {
    static var requestCount = 0
    static let delays = [30000, 20000, 10000, 7500, 5000, 2000, 1500, 1000, 700, 500]

    func autocompleteSuggestions(for query: String) -> Observable<[String]> {
        let delay = getDelay()
        return Observable.create { observer in
            let suggestions = Self.words.filter { $0.starts(with: query) }
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
        "abbreviated", "about", "accused", "across", "additional", "adolf", "advances", "aerial", "africa", "after", "afterwards", "again", "against", "aggressive", "agreement", "aimed", "aircraft", "alarmed", "albania", "alignment", "all", "alliance", "alliances", "allied", "allies", "allow", "along", "also", "although", "ambassador", "american", "anglo-german", "annexed", "announced", "appeasement", "april", "archipelago", "area", "asia", "assistance", "assured", "atlantic", "atomic", "attack", "august", "austria", "avoid", "axis", "balkans", "battle", "becoming", "been", "began", "begun", "behind", "being", "berlin", "bessarabia", "between", "blitz", "blurring", "bohemia", "bombing", "bombings", "bombs", "border", "britain", "british", "build-up", "campaign", "campaigns", "capabilities", "captured", "causes", "cede", "cementing", "central", "centres", "challenge", "chamberlain", "changed", "china", "cities", "city", "civil", "civilian", "civilians", "claims", "client", "co-operation", "cold", "common", "comply", "conceded", "concession", "concluded", "conducted", "conflict", "conflicts", "confrontational", "conquered", "considered", "continental", "continued", "continuing", "contributing", "controlled", "corridor", "council", "countries", "countries", "crimes", "crippled", "crisis", "critical", "culminating", "czechoslovak", "czechoslovakia", "damaged", "danzig", "deadliest", "debated", "december", "decided", "declaration", "declared", "declaring", "decolonisation", "defeat", "defeated", "defeats", "defined", "delay", "delivered", "demanded", "demands", "devastation", "died", "direct", "directly", "disease", "distinction", "document", "dominate", "dropped", "due", "during", "early", "east", "eastern", "economic", "effort", "emerged", "empire", "enabling", "encircle", "encouraged", "end", "enmities", "entire", "entry", "especially", "established", "estonia", "ethnic", "europe", "european", "eve", "exact", "exchange", "expansion", "extended", "face", "faced", "factors", "fall", "far", "fatalities", "finland", "first", "fleet", "followed", "following", "for", "forced", "forcing", "foreign", "forestall", "forge", "formal", "formalised", "formed", "formerly", "foster", "france", "franco-british", "free", "from", "front", "fronts", "furious", "further", "future", "general", "generally", "genocides", "german", "german-occupied", "germany", "german–polish", "global", "globe", "government", "great", "greatly", "greece", "guarantee", "guaranteed", "had", "half-century-long", "halted", "handover", "harbor", "have", "hearing", "henderson", "hiroshima", "history", "hitler", "holocaust", "hostilities", "human", "hungary", "identity", "immediately", "imminent", "included", "including", "independence", "industrial", "industries", "influence", "initiative", "integration", "intention", "interference", "international", "into", "invaded", "invading", "invasion", "invasions", "involved", "involving", "islands", "italian", "italo-ethiopian", "italy", "january", "japan", "japanese", "jewish", "joachim", "joseph", "july", "june", "key", "kingdom", "kingdoms", "klaipėda", "land", "largest", "lasted", "late", "later", "latvia", "leader", "leaders", "led", "liberation", "lithuania", "little", "losing", "losses", "made", "mainland", "maintain", "major", "majority", "making", "manchuria", "march", "marked", "massacres", "may", "meeting", "members", "memelland", "midway", "military", "million", "millions", "minister", "minority", "mobilise", "molotov–ribbentrop", "moravia", "more", "most", "moved", "much", "munich", "mutual", "nagasaki", "nations", "naval", "navy", "nazi", "near-simultaneous", "nearly", "negotiate", "negotiations", "neutralised", "neutrality", "nevile", "neville", "night", "non-aggression", "north", "nuclear", "occupied", "offensives", "often", "one", "only", "onset", "opening", "operation", "opposing", "opposition", "ordered", "other", "out", "own", "pacific", "pacific—cost", "pact", "participants", "partitioned", "pearl", "people", "permanent", "personnel", "played", "plebiscite", "pledge", "plenipotentiary", "poland", "poles", "policy", "polish", "political", "population", "possibility", "potsdam", "powers", "powers—china", "powers—forming", "pre-war", "predominantly", "pressing", "pretext", "prevent", "prevented", "primarily", "prime", "privately", "pro-german", "proceed", "promise", "prospect", "protectorate", "protocol", "provoking", "question", "raised", "reached", "recovery", "refusal", "refused", "regained", "region", "rejected", "relations", "remainder", "renounced", "republic", "requests", "resources", "response", "resulted", "retreat", "reversals", "ribbentrop", "right", "rising", "rival", "role", "romania", "same", "satisfied", "scientific", "secession", "second", "secret", "secretly", "security", "seizing", "sense", "september", "series", "served", "setbacks", "setting", "shortly", "sicily", "signed", "signing", "since", "sino-japanese", "situation", "slovak", "social", "solidarity", "soon", "southeast", "soviet", "soviet–japanese", "spanish", "speeches", "spheres", "split", "stage", "stalin", "stalingrad", "stalled", "starvation", "state", "stated", "states", "states—becoming", "steel", "strategic", "structure", "subsequent", "subsequently", "sudetenland", "suffered", "suicide", "superpowers", "support", "supremacy", "surrender", "tens", "tensions", "terms", "territorial", "territories", "territory", "than", "that", "the", "theatre", "their", "then", "therefore", "this", "threw", "to", "total", "towards", "travel", "treaties", "tribunals", "triggering", "tripartite", "troops", "trying", "turned", "two", "two-front", "ultimatum", "unconditional", "under", "union", "united", "upon", "uses", "vast", "victorious", "victory", "vote", "wake", "waned", "war", "war-mongers", "weapons", "western", "when", "which", "while", "whose", "wishes", "with", "world", "world", "worsen", "would", "zaolzie"
    ]

}

