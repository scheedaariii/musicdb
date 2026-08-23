// song_mock_data.dart
// Enthält die Startdaten für Songs.
// Die Bestandsdaten sind direkt mit ihrer Band verknüpft.

import '../domain/song.dart';

const List<Song> seedSongs = [
  Song(id: 'master-of-puppets', title: 'Master of Puppets', bandIds: ['metallica'], bandNames: ['Metallica'], durationSeconds: 515),
  Song(id: 'enter-sandman', title: 'Enter Sandman', bandIds: ['metallica'], bandNames: ['Metallica'], durationSeconds: 332),
  Song(id: 'nothing-else-matters', title: 'Nothing Else Matters', bandIds: ['metallica'], bandNames: ['Metallica'], durationSeconds: 388),
  Song(id: 'comfortably-numb', title: 'Comfortably Numb', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], durationSeconds: 383),
  Song(id: 'wish-you-were-here', title: 'Wish You Were Here', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], durationSeconds: 334),
  Song(id: 'another-brick-in-the-wall', title: 'Another Brick in the Wall', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], durationSeconds: 239),
  Song(id: 'one-more-time', title: 'One More Time', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], durationSeconds: 320),
  Song(id: 'around-the-world', title: 'Around the World', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], durationSeconds: 429),
  Song(id: 'get-lucky', title: 'Get Lucky', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], durationSeconds: 369),
  Song(id: 'smells-like-teen-spirit', title: 'Smells Like Teen Spirit', bandIds: ['nirvana'], bandNames: ['Nirvana'], durationSeconds: 301),
  Song(id: 'come-as-you-are', title: 'Come As You Are', bandIds: ['nirvana'], bandNames: ['Nirvana'], durationSeconds: 219),
  Song(id: 'du-hast', title: 'Du Hast', bandIds: ['rammstein'], bandNames: ['Rammstein'], durationSeconds: 234),
  Song(id: 'sonne', title: 'Sonne', bandIds: ['rammstein'], bandNames: ['Rammstein'], durationSeconds: 272),
  Song(id: 'hammer-smashed-face', title: 'Hammer Smashed Face', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], durationSeconds: 243),
  Song(id: 'devoured-by-vermin', title: 'Devoured by Vermin', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], durationSeconds: 206),
  Song(id: 'raining-blood', title: 'Raining Blood', bandIds: ['slayer'], bandNames: ['Slayer'], durationSeconds: 254),
  Song(id: 'angel-of-death', title: 'Angel of Death', bandIds: ['slayer'], bandNames: ['Slayer'], durationSeconds: 291),
  Song(id: 'alive', title: 'Alive', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], durationSeconds: 341),
  Song(id: 'jeremy', title: 'Jeremy', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], durationSeconds: 318),
  Song(id: 'firth-of-fifth', title: 'Firth of Fifth', bandIds: ['genesis'], bandNames: ['Genesis'], durationSeconds: 576),
  Song(id: 'land-of-confusion', title: 'Land of Confusion', bandIds: ['genesis'], bandNames: ['Genesis'], durationSeconds: 285),
  Song(id: 'firestarter', title: 'Firestarter', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], durationSeconds: 280),
  Song(id: 'breathe', title: 'Breathe', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], durationSeconds: 335),
  Song(id: 'head-like-a-hole', title: 'Head Like a Hole', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], durationSeconds: 299),
  Song(id: 'closer', title: 'Closer', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], durationSeconds: 373),
  Song(id: 'immortal-rites', title: 'Immortal Rites', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], durationSeconds: 247),
  Song(id: 'god-of-emptiness', title: 'God of Emptiness', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], durationSeconds: 316),
];
