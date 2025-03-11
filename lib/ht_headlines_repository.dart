/// repository for managing news headline data. It abstracts the data source
/// and provides a clean API for fetching, creating, updating, deleting, and
/// searching headlines.
library;

export 'package:ht_headlines_client/ht_headlines_client.dart'
    show
        Headline,
        HeadlineCreateException,
        HeadlineDeleteException,
        HeadlineNotFoundException,
        HeadlineUpdateException,
        HeadlinesException,
        HeadlinesFetchException,
        HeadlinesSearchException,
        HtHeadlinesClient;

export 'src/ht_headlines_repository.dart';
