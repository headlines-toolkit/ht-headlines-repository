A Dart package that provides a repository for managing news headlines data.
It abstracts the data source and provides a clean API for
fetching, creating, updating, deleting, and searching headlines.

## Features

- **Fetch Headlines:** Retrieve a paginated list of news headlines. Supports optional filtering using lists of `Category`, `Source`, and `Country` objects. Filtering logic is OR within each list and AND across different filter types (e.g., (category A OR B) AND (source X OR Y)).
- **Get Headline by ID:** Fetch a specific headline by its unique identifier.
- **Create Headline:** Add a new headline to the data source.
- **Update Headline:** Modify an existing headline in the data source.
- **Delete Headline:** Remove a headline from the data source.
- **Search Headlines:** Search for headlines based on a query string.
- **Stream Headlines:** Get a stream of headlines that updates periodically.
- **Error Handling:** Provides custom exceptions for specific error scenarios
  (e.g., `HeadlinesFetchException`, `HeadlineNotFoundException`, `HeadlineCreateException`, `HeadlineUpdateException`, `HeadlineDeleteException`, `HeadlinesSearchException`).

## Getting started

To use this package, add `ht_headlines_repository` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  ht_headlines_repository:
    git:
      url: https://github.com/headlines-toolkit/ht-headlines-repository.git
      ref: main
```

Then, import the package in your Dart code:

```dart
import 'package:ht_headlines_repository/ht_headlines_repository.dart';
```

## Usage

Create an instance of `HtHeadlinesRepository` by passing a `HtHeadlinesClient` instance.

```dart
import 'package:ht_headlines_client/ht_headlines_client.dart';
import 'package:ht_headlines_repository/ht_headlines_repository.dart';

void main() async {
  // Replace with your HtHeadlinesClient implementation
  final headlinesClient = MyHeadlinesClient();
  final headlinesRepository =
      HtHeadlinesRepository(client: headlinesClient);

  // --- getHeadlines ---
  try {
    // Fetch headlines (paginated)
    final headlinesPage1 = await headlinesRepository.getHeadlines(limit: 10);
    print('Page 1: ${headlinesPage1.items}');

    // Fetch headlines with filtering (Example)
    // Assume you have Category, Source, Country objects available
    final techCategory = Category(id: 'tech', name: 'Technology');
    final bbcSource = Source(id: 'bbc', name: 'BBC News');
    final usCountry = Country(id: 'us', isoCode: 'US', name: 'United States', flagUrl: '');

    final filteredHeadlines = await headlinesRepository.getHeadlines(
      limit: 5,
      categories: [techCategory], // Pass a list of Category objects
      sources: [bbcSource],      // Pass a list of Source objects
      eventCountries: [usCountry], // Pass a list of Country objects
    );
    print('Filtered Headlines: ${filteredHeadlines.items}');

    if (headlinesPage1.hasMore) {
      final headlinesPage2 = await headlinesRepository.getHeadlines(
        limit: 10,
        startAfterId: headlinesPage1.cursor,
      );
      print('Page 2: ${headlinesPage2.items}');
    }
  } on HeadlinesFetchException catch (e) {
    print('Error fetching headlines: $e');
  }

  // --- getHeadline ---
  try {
    final headline = await headlinesRepository.getHeadline(id: 'some_id');
    if (headline != null) {
      print('Headline: $headline');
    } else {
      print('Headline not found.');
    }
  } on HeadlineNotFoundException catch (e) {
    print('Error fetching headline: $e');
  } on HeadlinesFetchException catch (e) {
    print('Error fetching headline: $e');
  }

  // --- createHeadline ---
  // Assume Category, Source, Country objects are available if needed
  final generalCategory = Category(id: 'gen', name: 'General');

  try {
    final newHeadline = Headline(
      id: 'new_id', // ID is usually generated if not provided
      title: 'New Headline',
      description: 'This is a new headline.',
      url: 'https://example.com/new-headline',
      publishedAt: DateTime.now(),
    );
    final createdHeadline =
        await headlinesRepository.createHeadline(headline: newHeadline);
    print('Created Headline: $createdHeadline');
  } on HeadlineCreateException catch (e) {
    print('Error creating headline: $e');
  }

  // --- updateHeadline ---
  try {
    // Fetch or create the headline object you want to update
    final existingHeadline = await headlinesRepository.getHeadline(id: 'existing_id');
    if (existingHeadline == null) {
      print('Headline to update not found.');
      return;
    }
    final updatedHeadlineData = existingHeadline.copyWith(
      title: 'Updated Headline Title',
      description: 'This headline has been updated.',
      // Update other fields as needed, e.g., category
      category: generalCategory,
    );
    final result =
        await headlinesRepository.updateHeadline(headline: updatedHeadlineData);
    print('Updated Headline: $result');
  } on HeadlineNotFoundException catch (e) {
    print('Error updating headline (not found): $e');
  } on HeadlineUpdateException catch (e) {
    print('Error updating headline: $e');
  }

  // --- deleteHeadline ---
  try {
    await headlinesRepository.deleteHeadline(id: 'existing_id'); // Replace with existing ID
    print('Headline deleted successfully.');
  } on HeadlineDeleteException catch (e) {
    print('Error deleting headline: $e');
  }

  // --- searchHeadlines ---
  try {
    final searchedHeadlines =
        await headlinesRepository.searchHeadlines(query: 'example');
    print('Searched Headlines: $searchedHeadlines.items}');
  } on HeadlinesSearchException catch (e) {
    print('Error searching headlines: $e');
  }

  // --- getHeadlinesStream ---
  try {
    headlinesRepository
        .getHeadlinesStream(limit: 5, interval: const Duration(seconds: 30))
        .listen((headlines) {
      print('Streamed Headlines: ${headlines.items}');
    });
  } on HeadlinesFetchException catch (e) {
    print('Error fetching headlines stream: $e');
  }
}
```


## Additional information

This package is designed to be data source agnostic, allowing you to easily switch 
between different backend implementations by providing a different `HtHeadlinesClient`.