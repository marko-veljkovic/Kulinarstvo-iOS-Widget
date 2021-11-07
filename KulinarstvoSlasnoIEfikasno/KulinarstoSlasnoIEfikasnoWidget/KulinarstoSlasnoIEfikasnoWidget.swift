import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0])
            
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, recipe: RecipeModel.testData[0])
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, recipe: recipe(for: configuration))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func recipe(for configuration: ConfigurationIntent) -> Recipe {
        switch configuration.Recipe {
        case .omlet:
            return RecipeModel.testData[0]
        case .pirinac:
            return RecipeModel.testData[2]
        default:
            return RecipeModel.testData[0]
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    let recipe: Recipe
}

struct PlaceholderView : View {
    var body : some View {
        Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0]))
    }
}

struct Kulinarstvo_widgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var widgetFamily
    
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            RecipeView(recipe: entry.recipe)
                .widgetURL(entry.recipe.url)
        case .systemMedium:
            RecipeMediumView(recipe: entry.recipe, ingredients: entry.recipe.ingredients.count > 3 ? Array(entry.recipe.ingredients.dropLast(entry.recipe.ingredients.count - 3)) : entry.recipe.ingredients)
        default:
            Text("")
        }
    }
}

struct RecipeView: View {
    
    var recipe: Recipe
    
    var body: some View {
        ZStack {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                Spacer()
                Text(recipe.name)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }.padding(5)
    }
}

struct RecipeMediumView: View {
    let recipe: Recipe
    
    @State var ingredients: [String]
    
    @ViewBuilder
    var body: some View {
        HStack {
            RecipeView(recipe: recipe)
            VStack {
                Text("Sastojci: ")
                ForEach(ingredients, id: \.self) {ingredient in
                    VStack {
                        Text("- " + ingredient)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding([.trailing], 10)
        }
    }
}

@main
struct Kulinarstvo_widget: Widget {
    let kind: String = "KulinarstvoSlasnoIEfikasnoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Kulinarstvo_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recept na klik")
        .description("Dodaj svoj omiljeni recept na pocetni ekran")
    }
}

struct Kulinarstvo_widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .redacted(reason: .placeholder)
        }
            
    }
}
