import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        self.loadDataFile()
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: Datafeed.shared.favRecipes[0], parameterToShow: MainParameter.Sastojci.rawValue)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        self.loadDataFile()
        let entry = SimpleEntry(date: Date(), configuration: configuration, recipe: Datafeed.shared.favRecipes[0], parameterToShow: MainParameter.Sastojci.rawValue)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.loadDataFile()
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
        self.loadDataFile()
        return Datafeed.shared.favRecipes.first(where: {
            $0.name == configuration.Recipe?.identifier
        }) ?? Datafeed.shared.favRecipes[0]
    }
    
    func parametereToShow(for configuration: ConfigurationIntent) -> String {
        self.loadDataFile()
        switch configuration.ParameterToShow {
        case .sastojci:
            return MainParameter.Sastojci.rawValue
        case .priprema:
            return MainParameter.Priprema.rawValue
        default:
            return MainParameter.Sastojci.rawValue
        }
    }
    
    func loadDataFile() {
        if !Datafeed.shared.recipeModel.isLoaded {
            Datafeed.shared.recipeModel.loadFile()
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let recipe: Recipe
    let parameterToShow: String
}

// Enum for list names and easier collecting of selected parameter
enum MainParameter : String {
    case Sastojci, Priprema
}

// Placeholder view that is presented to user while main view is loading
struct PlaceholderView : View {
    var body : some View {
        Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: Datafeed.shared.favRecipes[0], parameterToShow: MainParameter.Sastojci.rawValue))
    }
}

// Main view that is presented to user relative to selected widget size
struct Kulinarstvo_widgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            ImageRecipeView(recipe: entry.recipe, isSmallView: true)
                .widgetURL(entry.recipe.url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .dark ? Color(AppTheme.backgroundUniversalGreen) : .white)
        case .systemMedium:
            Link(destination: entry.recipe.url ?? URL(fileURLWithPath: "")) {
                RecipeMediumView(recipe: entry.recipe, listName: entry.parameterToShow)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color(AppTheme.backgroundUniversalGreen) : .white)
            }
        case .systemLarge:
            Link(destination: entry.recipe.url ?? URL(fileURLWithPath: "")) {
                RecipeLargeView(recipe: entry.recipe, mainParameter: entry.parameterToShow)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorScheme == .dark ? Color(AppTheme.backgroundUniversalGreen) : .white)
            }
        default:
            Text("")
        }
    }
}

// View that present recipe image and name at the bottom of image
struct ImageRecipeView: View {
    var recipe: Recipe
    var isSmallView: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isSmallView {
                Image(recipe.imageName)
                    .resizable()
            }
            else {
                Image(recipe.imageName)
            }
            VStack {
                Text(recipe.name)
                    .foregroundColor(Color(colorScheme == .light ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen))
                    .padding(5)
                    .background(Color(colorScheme == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen).opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }.padding(5)
    }
}

// View that list all items forwarded to it (ingredients or steps)
struct ListItemsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var items: [String]
    @State var areAllItemsPrinted: Bool
    @State var listName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(listName): ")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(Color(colorScheme == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen))
            ForEach(items, id: \.self) {item in
                VStack {
                    Text("- " + item)
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 175, alignment: .leading)
                        .lineLimit(2)
                        .foregroundColor(Color(colorScheme == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen))
                }
            }
            if !areAllItemsPrinted {
                Text("   ...")
                    .foregroundColor(Color(colorScheme == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen))
            }
        }
    }
}

// View that check list lenght and chop it off if needed and then present it via ListItemsView
struct ListItemsWithOptionalChopingView : View {
    var itemsArray: [String]
    var lenghtLimit: Int
    var listName: String
    
    var body: some View {
        if itemsArray.count > lenghtLimit {
            let chopedItems = Array(itemsArray.dropLast(itemsArray.count - lenghtLimit))
            ListItemsView(items: chopedItems, areAllItemsPrinted: false, listName: listName)
        }
        else {
            ListItemsView(items: itemsArray, areAllItemsPrinted: true, listName: listName)
        }
    }
}

// View that represents medium size widget
struct RecipeMediumView : View {
    let recipe: Recipe
    
    @State var listName: String
    
    @ViewBuilder
    var body: some View {
        HStack {
            ImageRecipeView(recipe: recipe, isSmallView: false)
            ListItemsWithOptionalChopingView(itemsArray: listName == MainParameter.Sastojci.rawValue ? recipe.stringIngredients : recipe.steps, lenghtLimit: 7, listName: listName)
        }
    }
}

// View that represents large size widget
struct RecipeLargeView: View {
    var recipe: Recipe
    
    var mainParameter: String
    var secondParameter: String
    
    var mainArray: [String]
    var secondArray: [String]
    
    init(recipe: Recipe, mainParameter: String) {
        self.recipe = recipe
        self.mainParameter = mainParameter
        self.secondParameter = self.mainParameter == MainParameter.Sastojci.rawValue ? MainParameter.Priprema.rawValue : MainParameter.Sastojci.rawValue
        self.mainArray = self.mainParameter == MainParameter.Sastojci.rawValue ? self.recipe.stringIngredients : self.recipe.steps
        self.secondArray = self.mainParameter == MainParameter.Sastojci.rawValue ? self.recipe.steps : self.recipe.stringIngredients
    }
    
    @ViewBuilder
    var body: some View {
        if self.mainArray.count > 6 {
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    ImageRecipeView(recipe: recipe, isSmallView: false)
                    ListItemsWithOptionalChopingView(itemsArray: self.secondArray, lenghtLimit: 7, listName: secondParameter)
                }
                ListItemsWithOptionalChopingView(itemsArray: self.mainArray, lenghtLimit: 18, listName: mainParameter)
            }
            .fixedSize()
        }
        else if self.secondArray.count > 6 {
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    ImageRecipeView(recipe: recipe, isSmallView: false)
                    ListItemsView(items: self.mainArray, areAllItemsPrinted: true, listName: mainParameter)
                }
                ListItemsWithOptionalChopingView(itemsArray: self.secondArray, lenghtLimit: 18, listName: secondParameter)
            }
            .fixedSize()
        }
        else {
            VStack(spacing: 0) {
                ImageRecipeView(recipe: recipe, isSmallView: false)
                Spacer()
                HStack(alignment: .top, spacing: 5) {
                    ListItemsView(items: self.mainArray, areAllItemsPrinted: true, listName: mainParameter)
                    ListItemsView(items: self.secondArray, areAllItemsPrinted: true, listName: secondParameter)
                }
                Spacer()
            }
            .fixedSize()
        }
    }
}

@main
struct Kulinarstvo_widget: Widget {
    @Environment(\.colorScheme) var colorScheme
    
    let kind: String = "KulinarstvoSlasnoIEfikasnoWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Kulinarstvo_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recept na klik")
        .description("Dodaj svoj omiljeni recept na pocetni ekran")
    }
}

// View for previewing views on right side
struct Kulinarstvo_widget_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[0], parameterToShow: MainParameter.Sastojci.rawValue))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(AppTheme.backgroundUniversalGreen))
//                .preferredColorScheme(.dark)
            
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
