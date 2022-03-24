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
        // Show recipe in widget which user choose in configuration
        return Datafeed.shared.favRecipes.first(where: {
            $0.name == configuration.Recipe?.identifier
        }) ?? Datafeed.shared.favRecipes[0]
    }
    
    func parametereToShow(for configuration: ConfigurationIntent) -> String {
        self.loadDataFile()
        // Show main parameter in widget which user choose in configuration
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
    
//    func firstRecipeInSecondWidget(for configuration: ConfigurationIntent) -> Recipe {
//        self.loadDataFile()
//        return Datafeed.shared.favRecipes.first(where: {
//            $0.name == configuration.Recipe?.identifier
//        }) ?? Datafeed.shared.favRecipes[0]
//    }
}

struct SecondProvider : TimelineProvider {
    func loadDataFile() {
        if !Datafeed.shared.recipeModel.isLoaded {
            Datafeed.shared.recipeModel.loadFile()
        }
    }
    
    func placeholder(in context: Context) -> SecondEntry {
        self.loadDataFile()
        return SecondEntry(date: Date(), firstRecipe: Datafeed.shared.favRecipes[0], secondRecipe: Datafeed.shared.favRecipes[0], thirdRecipe: Datafeed.shared.favRecipes[0], fourthRecipe: Datafeed.shared.favRecipes[0])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SecondEntry) -> Void) {
        self.loadDataFile()
        let entry = SecondEntry(date: Date(), firstRecipe: Datafeed.shared.favRecipes[0], secondRecipe: Datafeed.shared.favRecipes[0], thirdRecipe: Datafeed.shared.favRecipes[0], fourthRecipe: Datafeed.shared.favRecipes[0])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SecondEntry>) -> Void) {
        self.loadDataFile()
        var entries: [SecondEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            
            var tmpFavoriteRecipesArray = Datafeed.shared.favRecipes
            
            var firstRecipe = RecipeModel.myTestData[0]
            var secondRecipe = RecipeModel.myTestData[0]
            var thirdRecipe = RecipeModel.myTestData[0]
            var fourthRecipe = RecipeModel.myTestData[0]
            
            if !tmpFavoriteRecipesArray.isEmpty {
                let firstRandomInt = Int.random(in: 0..<tmpFavoriteRecipesArray.count)
                firstRecipe = tmpFavoriteRecipesArray[firstRandomInt]
                tmpFavoriteRecipesArray.remove(at: firstRandomInt)
            }
            
            if !tmpFavoriteRecipesArray.isEmpty {
                let secondRandomInt = Int.random(in: 0..<tmpFavoriteRecipesArray.count)
                secondRecipe = tmpFavoriteRecipesArray[secondRandomInt]
                tmpFavoriteRecipesArray.remove(at: secondRandomInt)
            }
            
            if !tmpFavoriteRecipesArray.isEmpty {
                let thirdRandomInt = Int.random(in: 0..<tmpFavoriteRecipesArray.count)
                thirdRecipe = tmpFavoriteRecipesArray[thirdRandomInt]
                tmpFavoriteRecipesArray.remove(at: thirdRandomInt)
            }
            
            if !tmpFavoriteRecipesArray.isEmpty {
                let fourthRandomInt = Int.random(in: 0..<tmpFavoriteRecipesArray.count)
                fourthRecipe = tmpFavoriteRecipesArray[fourthRandomInt]
                tmpFavoriteRecipesArray.remove(at: fourthRandomInt)
            }
            
            let entry = SecondEntry(date: entryDate, firstRecipe: firstRecipe, secondRecipe: secondRecipe, thirdRecipe: thirdRecipe, fourthRecipe: fourthRecipe)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let recipe: Recipe
    let parameterToShow: String
}

struct SecondEntry: TimelineEntry {
    public let date: Date
    let firstRecipe: Recipe
    let secondRecipe: Recipe
    let thirdRecipe: Recipe
    let fourthRecipe: Recipe
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

// Main view that is presented to user relative to selected widget size
struct KulinarstvoSecondWidgetEntryView : View {
    var entry: SecondProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemLarge:
            RecipeSecondLargeView(firstRecipe: entry.firstRecipe, secondRecipe: entry.secondRecipe, thirdRecipe: entry.thirdRecipe, fourthRecipe: entry.fourthRecipe)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .dark ? Color(AppTheme.backgroundUniversalGreen) : .white)
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
    var screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isSmallView {
                Image(recipe.imageName)
                    .resizable()
            }
            else {
                Image(recipe.imageName)
                    .resizable()
                    .frame(width: screenSize.width/2.7, height: screenSize.width/2.7, alignment: .center)
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
    
    var screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(listName): ")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(Color(colorScheme == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen))
            ForEach(items, id: \.self) {item in
                VStack {
                    Text("- " + item)
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: screenSize.width/2.5, alignment: .leading)
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
//            .fixedSize()
        }
        else if self.secondArray.count > 6 {
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 10) {
                    ImageRecipeView(recipe: recipe, isSmallView: false)
                    ListItemsView(items: self.mainArray, areAllItemsPrinted: true, listName: mainParameter)
                }
                ListItemsWithOptionalChopingView(itemsArray: self.secondArray, lenghtLimit: 18, listName: secondParameter)
            }
//            .fixedSize()
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

struct RecipeSecondLargeView: View {
    var firstRecipe: Recipe
    var secondRecipe: Recipe
    var thirdRecipe: Recipe
    var fourthRecipe: Recipe
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Link(destination: firstRecipe.url ?? URL(fileURLWithPath: "")) {
                    ImageRecipeView(recipe: firstRecipe, isSmallView: true)
                }
                Link(destination: secondRecipe.url ?? URL(fileURLWithPath: "")) {
                    ImageRecipeView(recipe: secondRecipe, isSmallView: true)
                }
            }
            HStack {
                Link(destination: thirdRecipe.url ?? URL(fileURLWithPath: "")) {
                    ImageRecipeView(recipe: thirdRecipe, isSmallView: true)
                }
                Link(destination: fourthRecipe.url ?? URL(fileURLWithPath: "")) {
                    ImageRecipeView(recipe: fourthRecipe, isSmallView: true)
                }
            }
        }
    }
}

// Main struct for first widget type
struct KulinarstvoWidget: Widget {
    @Environment(\.colorScheme) var colorScheme
    
    let kind: String = "KulinarstvoSlasnoIEfikasnoWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Kulinarstvo_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recept na klik")
        .description("Dodaj svoj omiljeni recept na početni ekran")
    }
}

// Main struct for second widget type
struct KulinarstvoSecondWidget: Widget {
    @Environment(\.colorScheme) var colorScheme
    
    let kind: String = "KulinarstvoSlasnoIEfikasnoSecondWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SecondProvider()) { entry in
            KulinarstvoSecondWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nasumični recepti")
        .description("Nemaš ideju šta da jedeš danas? Neka ti aplikacija kaže")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct KulinarstvoWidgetBundle : WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        KulinarstvoWidget()
        KulinarstvoSecondWidget()
    }
}

// View for previewing views on right side
struct Kulinarstvo_widget_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Kulinarstvo_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), recipe: RecipeModel.testData[5], parameterToShow: MainParameter.Priprema.rawValue))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .preferredColorScheme(.dark)
            KulinarstvoSecondWidgetEntryView(entry: SecondEntry(date: Date(), firstRecipe: RecipeModel.testData[0], secondRecipe: RecipeModel.testData[0], thirdRecipe: RecipeModel.testData[0], fourthRecipe: RecipeModel.testData[0]))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
//            KulinarstvoSecondWidgetEntryView(entry: SecondEntry(date: Date(), firstRecipe: RecipeModel.testData[0], secondRecipe: RecipeModel.testData[1], thirdRecipe: RecipeModel.testData[2], fourthRecipe: RecipeModel.testData[3]))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
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
