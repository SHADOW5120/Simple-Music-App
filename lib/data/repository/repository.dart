import 'package:my_music/data/model/song.dart';
import 'package:my_music/data/source/source.dart';

abstract class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await _remoteDataSource.loadData().then((remoteSongs) {
      if (remoteSongs == null) {
        _localDataSource.loadData().then((localSongs) {
          if (localSongs != null) {
            songs.addAll(localSongs);
          }
        });
      } else {
        songs.addAll(remoteSongs);
      }
    });
    return songs;
  }
}


// other way to add data to cache
// Future<List<Song>?> loadData() async {
//   List<Song> songs = [];

//   // Try to load data from the remote data source
//   List<Song>? remoteSongs = await _remoteDataSource.loadData();
  
//   if (remoteSongs != null) {
//     // Add remote songs if available
//     songs.addAll(remoteSongs);
//   } else {
//     // If remote data is not available, load from local data source
//     List<Song>? localSongs = await _localDataSource.loadData();
    
//     if (localSongs != null) {
//       // Add local songs if available
//       songs.addAll(localSongs);
//     }
//   }

//   return songs;
// }
