import 'package:ht_categories_client/ht_categories_client.dart';
import 'package:ht_countries_client/ht_countries_client.dart';
import 'package:ht_headlines_client/ht_headlines_client.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:ht_sources_client/ht_sources_client.dart';
import 'package:rxdart/rxdart.dart';

/// {@template ht_headlines_repository}
/// A repository that manages headlines data.
///
/// This repository acts as an intermediary between the application
/// and the [HtHeadlinesClient], providing a single point of access
/// for headlines data and abstracting away the underlying data source.
/// {@endtemplate}
class HtHeadlinesRepository {
  /// {@macro ht_headlines_repository}
  const HtHeadlinesRepository({required HtHeadlinesClient client})
    : _client = client;

  final HtHeadlinesClient _client;

  /// Fetches a paginated list of headlines with optional filtering.
  ///
  /// Filtering Logic:
  /// - Within each list (`categories`, `sources`, `eventCountries`), the logic
  ///   is OR (e.g., headlines matching category A OR category B).
  /// - Across different filter types, the logic is AND (e.g., headlines
  ///   matching (category A OR B) AND (source X OR Y)).
  ///
  /// [limit] - The maximum number of headlines to return per page.
  /// [startAfterId] - The ID of the headline to start after (for pagination).
  /// [categories] - Optional list of [Category] objects to filter by.
  /// [sources] - Optional list of [Source] objects to filter by.
  /// [eventCountries] - Optional list of [Country] objects to filter by.
  ///
  /// Returns a [Future] that resolves to a [PaginatedResponse<Headline>].
  /// Throws [HeadlinesFetchException] if fetching fails.
  Future<PaginatedResponse<Headline>> getHeadlines({
    int? limit,
    String? startAfterId,
    List<Category>? categories,
    List<Source>? sources,
    List<Country>? eventCountries,
  }) async {
    try {
      final headlines = await _client.getHeadlines(
        limit: limit,
        startAfterId: startAfterId,
        categories: categories,
        sources: sources,
        eventCountries: eventCountries,
      );
      return PaginatedResponse<Headline>(
        items: headlines,
        cursor: headlines.isNotEmpty ? headlines.last.id : null,
        hasMore: headlines.length == limit,
      );
    } on HeadlinesFetchException catch (e) {
      throw HeadlinesFetchException(e.message);
    }
  }

  /// Fetches a stream of paginated headlines that periodically updates,
  /// with optional filtering.
  ///
  /// Filtering Logic:
  /// - Within each list (`categories`, `sources`, `eventCountries`), the logic
  ///   is OR (e.g., headlines matching category A OR category B).
  /// - Across different filter types, the logic is AND (e.g., headlines
  ///   matching (category A OR B) AND (source X OR Y)).
  ///
  /// [limit] - The maximum number of headlines to return per page.
  /// [startAfterId] - The ID of the headline to start after (for pagination).
  /// [categories] - Optional list of [Category] objects to filter by.
  /// [sources] - Optional list of [Source] objects to filter by.
  /// [eventCountries] - Optional list of [Country] objects to filter by.
  /// [interval] - The time interval between stream updates.
  ///
  /// Returns a [Stream] of [PaginatedResponse<Headline>].
  /// Throws [HeadlinesFetchException] if fetching fails during an update.
  Stream<PaginatedResponse<Headline>> getHeadlinesStream({
    int? limit,
    String? startAfterId,
    List<Category>? categories,
    List<Source>? sources,
    List<Country>? eventCountries,
    Duration interval = const Duration(minutes: 5),
  }) {
    return TimerStream(null, interval).startWith(null).asyncMap((_) {
      return getHeadlines(
        limit: limit,
        startAfterId: startAfterId,
        categories: categories,
        sources: sources,
        eventCountries: eventCountries,
      );
    }).distinct();
  }

  /// Fetches a specific headline by its unique identifier.
  ///
  /// Returns a [Future] that resolves to a [Headline] object if found.
  /// Returns `null` if no headline with the given [id] exists.
  /// Throws [HeadlineNotFoundException] if fetching fails.
  Future<Headline?> getHeadline({required String id}) async {
    try {
      return await _client.getHeadline(id: id);
    } on HeadlineNotFoundException catch (e) {
      throw HeadlineNotFoundException(e.message);
    } on HeadlinesFetchException catch (e) {
      throw HeadlinesFetchException(e.message);
    }
  }

  /// Creates a new headline.
  ///
  /// Returns a [Future] that resolves to the created [Headline] object.
  /// Throws [HeadlineCreateException] if creation fails.
  Future<Headline> createHeadline({required Headline headline}) async {
    try {
      return await _client.createHeadline(headline: headline);
    } on HeadlineCreateException catch (e) {
      throw HeadlineCreateException(e.message);
    }
  }

  /// Updates an existing headline.
  ///
  /// Returns a [Future] that resolves to the updated [Headline] object.
  /// Throws [HeadlineUpdateException] if updating fails.
  Future<Headline> updateHeadline({required Headline headline}) async {
    try {
      return await _client.updateHeadline(headline: headline);
    } on HeadlineUpdateException catch (e) {
      throw HeadlineUpdateException(e.message);
    }
  }

  /// Deletes a headline by its unique identifier.
  ///
  /// Returns a [Future] that completes when the headline is deleted.
  /// Throws [HeadlineDeleteException] if deletion fails.
  Future<void> deleteHeadline({required String id}) async {
    try {
      await _client.deleteHeadline(id: id);
    } on HeadlineDeleteException catch (e) {
      throw HeadlineDeleteException(e.message);
    }
  }

  /// Searches for headlines based on a query string.
  ///
  /// [limit] - The maximum number of headlines to return per page.
  /// [startAfterId] - The ID of the headline to start after (for pagination).
  ///
  /// Returns a [Future] that resolves to a [PaginatedResponse<Headline>].
  /// Throws [HeadlinesSearchException] if searching fails.
  Future<PaginatedResponse<Headline>> searchHeadlines({
    required String query,
    int? limit,
    String? startAfterId,
  }) async {
    try {
      final headlines = await _client.searchHeadlines(
        query: query,
        limit: limit,
        startAfterId: startAfterId,
      );
      final hasMore = headlines.length == limit;
      return PaginatedResponse<Headline>(
        items: headlines,
        cursor: headlines.isNotEmpty ? headlines.last.id : null,
        hasMore: hasMore,
      );
    } on HeadlinesSearchException catch (e) {
      throw HeadlinesSearchException(e.message);
    }
  }
}
