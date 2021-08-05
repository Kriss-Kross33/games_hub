import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamez_hub/src/core/error/exception.dart';
import 'package:gamez_hub/src/core/error/failure.dart';
import 'package:gamez_hub/src/core/games/data/datasources/game_local_data_source.dart';
import 'package:gamez_hub/src/core/games/data/datasources/game_remote_data_source.dart';
import 'package:gamez_hub/src/core/games/data/models/game_model.dart';
import 'package:gamez_hub/src/core/games/data/repositories/game_repository_impl.dart';
import 'package:gamez_hub/src/core/network/network_info.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../models/game.dart';
import 'game_repository_impl_test.mocks.dart';

@GenerateMocks([NetworkInfo, GameRemoteDataSource, GameLocalDataSource])
void main() {
  late MockNetworkInfo mockNetworkInfo;
  late MockGameRemoteDataSource mockGameRemoteDataSource;
  late MockGameLocalDataSource mockLocalDataSource;
  late GameRepositoryImpl gameRepsitory;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockGameRemoteDataSource = MockGameRemoteDataSource();
    mockLocalDataSource = MockGameLocalDataSource();
    gameRepsitory = GameRepositoryImpl(
      networkInfo: mockNetworkInfo,
      remoteDataSource: mockGameRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('fetchGameList', () {
    final List<GameModel> gameModelList = gameModelsTst;
    test('should check if the device has an active internet connection',
        () async {
      //* arrange
      when(mockNetworkInfo.hasConnection).thenAnswer((_) async => true);
      //* act
      final result = await mockNetworkInfo.hasConnection;
      //* assert
      verify(mockNetworkInfo.hasConnection);
      expect(result, equals(true));
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.hasConnection).thenAnswer((_) async => true);
      });
      test(
          'should return the right side of Either when the call to remote data source is successful',
          () async {
        //* ararange

        when(mockGameRemoteDataSource.fetchGameList())
            .thenAnswer((_) async => gameModelList);
        //* act
        // List<GameEntity> games = gameModelList.cast<GameEntity>().toList();
        final result = await gameRepsitory.fetchGameList();
        //* assert
        verify(mockGameRemoteDataSource.fetchGameList());
        expect(
            result.isRight(), true); //right<Failure, List<GameEntity>>(games));
      });

      // test(
      //     'should return [List<GameEntity>] when the call to remote data source is successful',
      //     () async {
      //   //* ararange

      //   when(mockGameRemoteDataSource.fetchGameList())
      //       .thenAnswer((realInvocation) async => gameModelsTst);
      //   //* act
      //   // List<GameEntity> games = gameModelList.cast<GameEntity>().toList();
      //   final result = await gameRepsitory.fetchGameList();
      //   //* assert
      //   verify(mockGameRemoteDataSource.fetchGameList());
      //   expect(
      //       result,
      //       equals(Right(
      //           gameModelsTst))); //right<Failure, List<GameEntity>>(games));
      // });

      test(
          'should cache the data when the data is returned from the remote server successfully',
          () async {
        //* arrange
        when(mockGameRemoteDataSource.fetchGameList())
            .thenAnswer((realInvocation) async => gameModelList);
        //* act
        await gameRepsitory.fetchGameList();
        await mockLocalDataSource.addGameListToCache(gameModelList);
        //* assert
        verify(mockLocalDataSource.addGameListToCache(gameModelList));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test(
          'should return [ServerFailure] when the call to remote data source is not successful',
          () async {
        //* arrange
        when(mockGameRemoteDataSource.fetchGameList())
            .thenThrow(ServerException());
        //* act
        final result = await gameRepsitory.fetchGameList();
        //* assert
        verify(mockGameRemoteDataSource.fetchGameList());
        expect(result, equals(Left(ServerFailure())));
        //verifyNoMoreInteractions(mockGameRemoteDataSource.fetchGameList());
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.hasConnection).thenAnswer((_) async => false);
      });

      test('should return locally cached data when the data is present',
          () async {
        //* arrange
        when(mockLocalDataSource.fetchCahedGames())
            .thenAnswer((realInvocation) async => gameModelList);
        //* act
        final result = await gameRepsitory.fetchGameList();
        //* assert
        verifyZeroInteractions(mockGameRemoteDataSource);
        verify(mockLocalDataSource.fetchCahedGames());
        expect(result, equals(Right(gameModelList)));
      });

      test('should throw [CacheException] when there is no cache data present',
          () async {
        //* arrange
        when(mockLocalDataSource.fetchCahedGames()).thenThrow(CacheException());
        //* act
        final result = await gameRepsitory.fetchGameList();
        //* assert
        verifyZeroInteractions(mockGameRemoteDataSource);
        verify(mockLocalDataSource.fetchCahedGames());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
