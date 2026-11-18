import SwiftUI

/// What is known about a topic's notes. Only pages actually read in Notion carry a
/// state other than `.shelved`, so the room never claims progress that has not happened.
enum BookState: String {
    case shelved, blank, written

    var label: String {
        switch self {
        case .shelved: "On the shelf"
        case .blank: "Blank pages, waiting for your notes"
        case .written: "Holds your notes"
        }
    }
}

struct Topic: Identifiable, Hashable {
    let id: String
    let title: String
    let shelf: String
    let state: BookState

    var notionURL: URL? { URL(string: "https://www.notion.so/\(id)") }
}

struct Shelf: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let topics: [Topic]
}

struct Wing: Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let symbol: String
    let tint: Color
    let shelves: [Shelf]

    var topics: [Topic] { shelves.flatMap(\.topics) }
}

enum KnowledgeLibrary {
    static var topicCount: Int { wings.reduce(0) { $0 + $1.topics.count } }

    static let wings: [Wing] = [
        Wing(id: "science", name: "Science Hall", tagline: "How the world works", symbol: "atom",
             tint: Color(red: 0.42, green: 0.62, blue: 0.50), shelves: [
                shelf("Maths", """
                Foundations|2983d81501e04fcbad863eb92777cf4a
                Counting|0bec1bfca3e045f49ca3494e8af82eac
                Number Systems|ff8a44958820448496248607cda0af7a
                Structures|ec94693a31d64c05a873ef5002fcee71
                Spaces|e68ca24958224953bd332bd45a813f56
                Changes|e6628d1f9ebd43e8a76f94627f95c0cd
                Control Theory|2417577dbc5a492f86ac625e09299e9d
                Numerical Analysis|3ef1a013934f4543b58fe2d84e700d56
                Probability|2d53ff086ffe490391a50fbb58bd79a3
                Statistics|b68daab571144a51b94c6656ec56ab26
                Optimization|8bd791dd37014d4ab31354e5730642fb
                Algebra|96bee669e033410f9931b42f6492f849
                Discrete|fec51c577066457aa2ca4fb4ba65f8f6
                """),
                shelf("Physics", """
                Classical Mechanics|cca6fb9a7954405b923103d1236d39c1
                Thermodynamics|50cc11d8fc0546a3b5133efb31296a9b|blank
                Fluid Mechanics|8e0fb50752f048d1aa810cf8ab9e72df
                Quantum Physics|69d60b409024446e94be6ce89052ed43
                Electricity|db647cfdc54a43cfa02ee02cba69cce4
                Magnetism|d239fd8d27234c9d9a71c3903af7c9a4
                Solid Mechanics|18404a7765ed4fceaf4020dd97ad9594
                """),
                shelf("Chemistry", """
                Organic Chemistry|a1859f6c755b4fed80dea4c31c844dd9
                Inorganic Chemistry|67089ae5d9e642b190878e97f00daae5
                Physical Chemistry|baf3868545b946ca98d28d0d601c6b8b
                """),
                shelf("Biology", """
                Cellular|472f20bdac1a441d9e120769d271b9da
                Molecular|056483a647cc4d8ca3ee5b2a07bbc551
                Structural|71f1faf835454bd4b368d28ae1127fee
                Biochemistry|d711933afa25436c9895e85eac0010a2
                Biophysics|6263dab0683544349c92c3340b7d01ae
                Quantum Biology|f317e1def0fa443eabf5ccb39f7b7380
                Genetics|14bac0410e724c988b5496899d42a282
                Bioinformatics|67aba4453c734119b5c4b6a1e6f5a7e0
                Biomathematics|fb07925985af4dc39a06c9b8e8938577
                Developmental Biology|17e36cc7427840e6b12c0b73bab7c41e
                Anatomy|61b79688cd3540f4877cf66a3aba140a
                Biomechanics|a4b631cafe224f6ca122891c93519bf0
                Physiology|c72d4898a22942089ee3499477f1607f
                Immunology|ca124f7f5b11468f9c21b6ba6c534404
                Bioengineering|d6e5b277dfe94a13826aadf4fe531129
                Neuroscience|3be5c0f716984cb3a2d9942c56ac7e4b|blank
                Ecology|bee6c3c4308e4608b2b81795453ecd79
                Zoology|f49402257ae7473bba61bf37104b19b9
                Botany|66c734e56dfa44f0a38324b417eed30d
                Marine Biology|ceac5f3636194474866f06e3c3bd3521
                Pathology|e094297231884bf8bd3ac6b6b7888fc6
                Epidemiology|c57dad2c16af413f83694afbe351418d
                Evolutionary Biology|cc3221c7a6ca46b391fbf53d9b63f649
                Astrobiology|3c9314da93264bcdb477275556240772
                Body Science|3552d3a1919480db944fd873da8e6f0c
                """),
             ]),
        Wing(id: "engineering", name: "Engineering Wing", tagline: "How things get built", symbol: "gearshape.2",
             tint: Color(red: 0.36, green: 0.55, blue: 0.70), shelves: [
                shelf("Computing", """
                Computer Science|b44709af1aef4b30b399273e52c61e86
                Computer Architecture|b8bfc8faefe7419b914d31bff98f18be
                Software Engineering|c10f95f1b97241f5afcf7e5779b37cc3
                Web Development|067f7b4aa23d4b78b48ed1b63a6ce07b
                Development Essentials|710871e01efd468da34cc21ba7fbf321
                Cloud Computing|0a9d6c0137bf4241a67027e8b70d6c16
                Data & Computational Sciences|0c073d098d514a399369cc477a4d06df
                Extended Reality|b8f4f52a8f8c45f2b103a14f0cda7d30
                Cryptography|6ee0743f970b41009ac8d40d29b8c5f2
                Hacking|6f077e09ccc845fba857443f7e2f8098
                Emerging Technologies|95a048312832458db8981613cc41dbd7
                Dev Ops|6812e981b1bd42ffb6f9fb889bc8688d
                Blockchain|11af8902cb1945818613cbeaa1ebe571
                Mobile Engineering|2442d3a1919480e8a40bf3eced1dbc3c
                Rust|32d2d3a1919480529f10f27885f51487
                Internet of Things|d2de2c8a13dd40f7b4ade03ea0f6a99c
                Digital Twins|a5fd6fad6899427e87cd2b0448ce907e
                """),
                shelf("Artificial Intelligence", """
                Artificial Intelligence|22bbaf2edb7442728bc4443bf68c771b|written
                AI Programs|b1f40dadaf064df5966eb4420dc54787
                Generative AI Engineering|a40acdcc158d495f841ae3e2e99acaba|written
                NLP|75b6b0926fbc49dc880801ae36fb3894
                AI Automation|1ff2d3a191948048bb42f005ddd1642a
                Computer Vision|29f499b7586443999f18e4728143ace1
                """),
                shelf("Automobile", """
                Automobile Chassis & Body|95367d1fbcd74d6884ca8155b4596d5e
                Internal Combustion Engines|2cc6d5280be24a4a8010095b47d08648
                """),
                shelf("Aerospace", """
                Introduction to Aerospace|e9aaebfb672342248228fb207ced0690
                Aircraft Propulsion|2365cef8ecd649b3a004a556dcbce4ff
                Aerospace Structural Mechanics|aef46d29798c4294af003dd989e435b1
                Flight Mechanics|30c5a9ee7d5b46ee8fe1bd052678ae7e
                """),
             ]),
        Wing(id: "merchant", name: "Merchant’s Corner", tagline: "How value is made", symbol: "scalemass",
             tint: Color(red: 0.80, green: 0.56, blue: 0.27), shelves: [
                shelf("Product Thinking", """
                User Experience|0d747db4deaa433a8f6a3872f7519c6a
                User Research|a4c082ca69804d7da49ef01dc33ae9d0
                Business Analysis|1031dc9a15384ac9a39e055c3a2a850d
                Market Research|a72130f1f52b4dfb9bf5d8abeb41b1ec
                Product Design|37a2d3a1919480c6aa92d2417ca7b615
                """),
                shelf("Business Management", """
                Strategy|7515f8c1aa194aabad1728a170527b23
                Operations|2200fd65217544a49adb6344a9da4e52
                Finance|27578ad77e594414a178a6c4a723ceb2
                Human Resources|118cff2a51054680a45b83084387dce3
                Research & Development|9d9faa19b72e4318b5875fe8aab79488
                Corporate Social Responsibility|4d801c7670ad48fb900bf22bb7673461
                Marketing|3382d3a1919480219dd5d6fa9c5efb9d
                """),
                shelf("Strategy", """
                Game Theory|c17ab6a728e6458fb0721a3ab6fd0802
                Competitive Strategy|10c2d3a1919480c99947d678fbb0e8f4
                """),
                shelf("Economics", """
                Microeconomics|dab1148232b045fda9b513d5f6181db2|blank
                Macroeconomics|7d9b779c533a49f087d11cca36d6059c
                Behavioral Economics|6f5caf97d8664071bf5d3ff3cb859d8e
                """),
             ]),
        Wing(id: "fireside", name: "Fireside Nook", tagline: "How to think and live", symbol: "flame",
             tint: Color(red: 0.76, green: 0.36, blue: 0.27), shelves: [
                shelf("Life", """
                Personal Finance|4d73d3813d854431ba61d7f24b64914b
                Meditation & Mindfulness|2571db99477a4386a6a98661266ef096
                Philosophy|116721eb50724a25b6238eb1ee7ffe1b
                """),
                shelf("Psychology", """
                Psychoanalysis|74a1ab507cb4402f9074c653a54536c4
                Cognitive Behavioral Therapy|1592daec16134f20a0b7683b15faa2c6
                Neuro Linguistic Programming|0ad2af5e96fb475d98e2a6c5f632b841
                """),
                shelf("Thinking", """
                Design Thinking|654f80134bf3420ea5126cbcd3c8c9c2
                Systems Thinking|2b98f752649640f694425d676bd9ff3a
                Storytelling|2c26001550bd4f71b0aa9feae39bc5a8|written
                """),
             ]),
    ]

    private static func shelf(_ name: String, _ rows: String) -> Shelf {
        let topics = rows.split(separator: "\n").map { row -> Topic in
            let parts = row.trimmingCharacters(in: .whitespaces).split(separator: "|").map(String.init)
            return Topic(id: parts[1], title: parts[0], shelf: name,
                         state: parts.count > 2 ? BookState(rawValue: parts[2]) ?? .shelved : .shelved)
        }
        return Shelf(name: name, topics: topics)
    }
}
