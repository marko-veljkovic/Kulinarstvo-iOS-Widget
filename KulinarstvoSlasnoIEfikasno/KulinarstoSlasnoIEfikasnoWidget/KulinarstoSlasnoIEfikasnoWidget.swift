import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0], parameterToShow: "Sastojci")
            
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, recipe: RecipeModel.testData[0], parameterToShow: "Sastojci")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, recipe: recipe(for: configuration), parameterToShow: parametereToShow(for: configuration))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func recipe(for configuration: ConfigurationIntent) -> Recipe {
        return RecipeModel.testData.first(where: {
            $0.name == configuration.Recipe?.identifier
        }) ?? RecipeModel.testData[0]
    }
    
    func parametereToShow(for configuration: ConfigurationIntent) -> String {
        switch configuration.ParameterToShow {
        case .sastojci:
            return "Sastojci"
        case .priprema:
            return "Priprema"
        default:
            return "Sastojci"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let recipe: Recipe
    let parameterToShow: String
}

struct PlaceholderView : View {
    var body : some View {
        Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0], parameterToShow: "Sastojci"))
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
            if entry.parameterToShow == "Sastojci" {
                RecipeMediumView(recipe: entry.recipe, ingredients: entry.recipe.ingredients.count > 7 ? Array(entry.recipe.ingredients.dropLast(entry.recipe.ingredients.count - 7)) : entry.recipe.ingredients, isAllIngredientsPrinted: entry.recipe.ingredients.count <= 7, listName: "Sastojci")
            }
            else {
                RecipeMediumView(recipe: entry.recipe, ingredients: entry.recipe.steps.count > 7 ? Array(entry.recipe.steps.dropLast(entry.recipe.steps.count - 7)) : entry.recipe.steps, isAllIngredientsPrinted: entry.recipe.steps.count <= 7, listName: "Priprema")
            }
            
            
        case .systemLarge:
            RecipeLargeView(
                recipe: entry.recipe,
                ingredients: entry.recipe.steps.count >= 7 ?
                    Array(entry.recipe.ingredients.dropLast(entry.recipe.ingredients.count - 7)) :
                    entry.recipe.ingredients.count > 18 ?
                    Array(entry.recipe.ingredients.dropLast(entry.recipe.ingredients.count - 18)) :
                    entry.recipe.ingredients,
                isAllIngredientsPrinted: (entry.recipe.ingredients.count < 20 || entry.recipe.steps.count <= 7),
                steps: entry.recipe.steps.count > 18 ?
                    Array(entry.recipe.steps.dropLast(entry.recipe.steps.count - 18)) :
                    entry.recipe.steps,
                isAllStepsPrinted: entry.recipe.steps.count <= 18)
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
//                .fixedSize(horizontal: true, vertical: true)
//                .aspectRatio(contentMode: .fit)
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

struct ImageRecipeView: View {
    var recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(recipe.imageName)
//                .resizable()
//                .fixedSize(horizontal: true, vertical: true)
//                .aspectRatio(contentMode: .fit)
            VStack {
//                Spacer()
                Text(recipe.name)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }.padding(5)
    }
}

struct ListItemsView: View {
    
    @State var items: [String]
    @State var areAllItemsPrinted: Bool
    @State var listName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(listName): ")
            ForEach(items, id: \.self) {item in
                VStack {
                    Text("- " + item)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(width: 175, alignment: .leading)
                        .lineLimit(2)
                }
            }
            if !areAllItemsPrinted {
                Text("   ...")
            }
        }
    }
}

struct RecipeMediumView: View {
    let recipe: Recipe
    
    @State var ingredients: [String]
    @State var isAllIngredientsPrinted: Bool
    @State var listName: String
    
    @ViewBuilder
    var body: some View {
        HStack {
            ImageRecipeView(recipe: recipe)
            ListItemsView(items: ingredients, areAllItemsPrinted: isAllIngredientsPrinted, listName: listName)
        }
    }
}

struct RecipeLargeView: View {
    var recipe: Recipe
    
    @State var ingredients: [String]
    @State var isAllIngredientsPrinted: Bool
    
    @State var steps: [String]
    @State var isAllStepsPrinted: Bool
    
    @ViewBuilder
    var body: some View {
        if steps.count > 6 {
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    ImageRecipeView(recipe: recipe)
                    ListItemsView(items: ingredients, areAllItemsPrinted: isAllIngredientsPrinted, listName: "Sastojci")
                }
                ListItemsView(items: steps, areAllItemsPrinted: isAllStepsPrinted, listName: "Priprema")
            }
            .fixedSize()
        }
        else if ingredients.count > 6 {
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    ImageRecipeView(recipe: recipe)
                    ListItemsView(items: steps, areAllItemsPrinted: isAllStepsPrinted, listName: "Priprema")
                }
                ListItemsView(items: ingredients, areAllItemsPrinted: isAllIngredientsPrinted, listName: "Sastojci")
            }
            .fixedSize()
        }
        else {
            VStack(spacing: 0) {
                ImageRecipeView(recipe: recipe)
                HStack(alignment: .top, spacing: 5) {
                    ListItemsView(items: ingredients, areAllItemsPrinted: isAllIngredientsPrinted, listName: "Sastojci")
                    ListItemsView(items: steps, areAllItemsPrinted: isAllStepsPrinted, listName: "Priprema")
                }
            }
            .fixedSize()
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
            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0], parameterToShow: "Sastojci"))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
//            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0]))
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//
//            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[2]))
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//            PlaceholderView()
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
//                .redacted(reason: .placeholder)
        }
            
    }
}
