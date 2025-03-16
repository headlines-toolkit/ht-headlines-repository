import 'package:ht_headlines_repository/ht_headlines_repository.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHtHeadlinesClient extends Mock implements HtHeadlinesClient {}

class FakeHeadline extends Fake implements Headline {}

void main() {
  group('HtHeadlinesRepository', () {
    late HtHeadlinesClient client;
    late HtHeadlinesRepository repository;

    setUpAll(() {
      registerFallbackValue(FakeHeadline());
    });

    setUp(() {
      client = MockHtHeadlinesClient();
      repository = HtHeadlinesRepository(client: client);
    });

    group('getHeadlines', () {
      const limit = 10;
      const startAfterId = 'abc';
      const category = 'general';
      const source = 'bbc';
      const eventCountry = 'US';

      final headlines = List.generate(
        limit,
        (index) => Headline(id: '$index', title: 'Headline $index'),
      );

      test('successfully fetches headlines', () async {
        when(
          () => client.getHeadlines(
            limit: limit,
            startAfterId: startAfterId,
            category: category,
            source: source,
            eventCountry: eventCountry,
          ),
        ).thenAnswer((_) async => headlines);

        final result = await repository.getHeadlines(
          limit: limit,
          startAfterId: startAfterId,
          category: category,
          source: source,
          eventCountry: eventCountry,
        );

        expect(
          result,
          equals(
            PaginatedResponse<Headline>(
              items: headlines,
              cursor: headlines.last.id,
              hasMore: true,
            ),
          ),
        );
      });

      test('throws HeadlinesFetchException on client failure', () async {
        when(
          () => client.getHeadlines(
            limit: limit,
            startAfterId: startAfterId,
            category: category,
            source: source,
            eventCountry: eventCountry,
          ),
        ).thenThrow(const HeadlinesFetchException('Failed to fetch headlines'));

        expect(
          () => repository.getHeadlines(
            limit: limit,
            startAfterId: startAfterId,
            category: category,
            source: source,
            eventCountry: eventCountry,
          ),
          throwsA(isA<HeadlinesFetchException>()),
        );
      });
    });

    group('getHeadlinesStream', () {
      const limit = 10;
      const startAfterId = 'abc';
      const category = 'general';
      const source = 'bbc';
      const eventCountry = 'US';

      final headlines = List.generate(
        limit,
        (index) => Headline(id: '$index', title: 'Headline $index'),
      );
      test('successfully fetches headlines stream', () async {
        when(
          () => client.getHeadlines(
            limit: limit,
            startAfterId: startAfterId,
            category: category,
            source: source,
            eventCountry: eventCountry,
          ),
        ).thenAnswer((_) async => headlines);

        final result = repository.getHeadlinesStream(
          limit: limit,
          startAfterId: startAfterId,
          category: category,
          source: source,
          eventCountry: eventCountry,
          interval: const Duration(milliseconds: 100),
        );

        expect(
          result,
          emitsInOrder([
            PaginatedResponse<Headline>(
              items: headlines,
              cursor: headlines.last.id,
              hasMore: true,
            ),
          ]),
        );
      });
    });

    group('getHeadline', () {
      const id = '123';
      const headline = Headline(id: id, title: 'Headline 1');

      test('successfully fetches a headline', () async {
        when(
          () => client.getHeadline(id: id),
        ).thenAnswer((_) async => headline);

        final result = await repository.getHeadline(id: id);

        expect(result, equals(headline));
      });

      test(
        'throws HeadlineNotFoundException if headline is not found',
        () async {
          when(
            () => client.getHeadline(id: id),
          ).thenThrow(const HeadlineNotFoundException('Headline not found'));

          expect(
            () => repository.getHeadline(id: id),
            throwsA(isA<HeadlineNotFoundException>()),
          );
        },
      );

      test('throws HeadlinesFetchException on client failure', () async {
        when(
          () => client.getHeadline(id: id),
        ).thenThrow(const HeadlinesFetchException('Failed to fetch'));

        expect(
          () => repository.getHeadline(id: id),
          throwsA(isA<HeadlinesFetchException>()),
        );
      });
    });

    group('createHeadline', () {
      const headline = Headline(id: '123', title: 'Headline 1');

      test('successfully creates a headline', () async {
        when(
          () => client.createHeadline(headline: any(named: 'headline')),
        ).thenAnswer((_) async => headline);

        final result = await repository.createHeadline(headline: headline);

        expect(result, equals(headline));
        verify(() => client.createHeadline(headline: headline)).called(1);
      });

      test('throws HeadlineCreateException on client failure', () async {
        when(
          () => client.createHeadline(headline: any(named: 'headline')),
        ).thenThrow(const HeadlineCreateException('Failed to create'));

        expect(
          () => repository.createHeadline(headline: headline),
          throwsA(isA<HeadlineCreateException>()),
        );
      });
    });

    group('updateHeadline', () {
      const headline = Headline(id: '123', title: 'Headline 1');

      test('successfully updates a headline', () async {
        when(
          () => client.updateHeadline(headline: any(named: 'headline')),
        ).thenAnswer((_) async => headline);

        final result = await repository.updateHeadline(headline: headline);

        expect(result, equals(headline));
        verify(() => client.updateHeadline(headline: headline)).called(1);
      });

      test('throws HeadlineUpdateException on client failure', () async {
        when(
          () => client.updateHeadline(headline: any(named: 'headline')),
        ).thenThrow(const HeadlineUpdateException('Failed to update'));

        expect(
          () => repository.updateHeadline(headline: headline),
          throwsA(isA<HeadlineUpdateException>()),
        );
      });
    });

    group('deleteHeadline', () {
      const id = '123';

      test('successfully deletes a headline', () async {
        when(() => client.deleteHeadline(id: id)).thenAnswer((_) async {});

        await repository.deleteHeadline(id: id);

        verify(() => client.deleteHeadline(id: id)).called(1);
      });

      test('throws HeadlineDeleteException on client failure', () async {
        when(
          () => client.deleteHeadline(id: id),
        ).thenThrow(const HeadlineDeleteException('Failed to delete'));

        expect(
          () => repository.deleteHeadline(id: id),
          throwsA(isA<HeadlineDeleteException>()),
        );
      });
    });

    group('searchHeadlines', () {
      const query = 'searchTerm';
      const limit = 10;
      const startAfterId = 'abc';
      final headlines = List.generate(
        limit,
        (index) => Headline(id: '$index', title: 'Headline $index'),
      );

      test('successfully searches headlines', () async {
        when(
          () => client.searchHeadlines(
            query: query,
            limit: limit,
            startAfterId: startAfterId,
          ),
        ).thenAnswer((_) async => headlines);

        final result = await repository.searchHeadlines(
          query: query,
          limit: limit,
          startAfterId: startAfterId,
        );

        expect(
          result,
          equals(
            PaginatedResponse<Headline>(
              items: headlines,
              cursor: headlines.last.id,
              hasMore: true,
            ),
          ),
        );
      });

      test('throws HeadlinesSearchException on client failure', () async {
        when(
          () => client.searchHeadlines(
            query: query,
            limit: limit,
            startAfterId: startAfterId,
          ),
        ).thenThrow(const HeadlinesSearchException('Failed to search'));

        expect(
          () => repository.searchHeadlines(
            query: query,
            limit: limit,
            startAfterId: startAfterId,
          ),
          throwsA(isA<HeadlinesSearchException>()),
        );
      });
    });
  });
}
