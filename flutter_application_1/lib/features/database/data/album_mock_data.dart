// album_mock_data.dart
// Enthält die Startdaten für Alben.
// Über bandIds sind die Alben mit ihren Bands verknüpft.

import '../domain/album.dart';

const List<Album> seedAlbums = [
  Album(id: 'master-of-puppets', title: 'Master of Puppets', bandIds: ['metallica'], bandNames: ['Metallica'], releaseDate: '1986'),
  Album(id: 'metallica-the-black-album', title: 'Metallica (The Black Album)', bandIds: ['metallica'], bandNames: ['Metallica'], releaseDate: '1991'),
  Album(id: 'the-dark-side-of-the-moon', title: 'The Dark Side of the Moon', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], releaseDate: '1973'),
  Album(id: 'wish-you-were-here', title: 'Wish You Were Here', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], releaseDate: '1975'),
  Album(id: 'the-wall', title: 'The Wall', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], releaseDate: '1979'),
  Album(id: 'homework', title: 'Homework', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], releaseDate: '1997'),
  Album(id: 'discovery', title: 'Discovery', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], releaseDate: '2001'),
  Album(id: 'random-access-memories', title: 'Random Access Memories', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], releaseDate: '2013'),
  Album(id: 'nevermind', title: 'Nevermind', bandIds: ['nirvana'], bandNames: ['Nirvana'], releaseDate: '1991'),
  Album(id: 'in-utero', title: 'In Utero', bandIds: ['nirvana'], bandNames: ['Nirvana'], releaseDate: '1993'),
  Album(id: 'herzeleid', title: 'Herzeleid', bandIds: ['rammstein'], bandNames: ['Rammstein'], releaseDate: '1995'),
  Album(id: 'mutter', title: 'Mutter', bandIds: ['rammstein'], bandNames: ['Rammstein'], releaseDate: '2001'),
  Album(id: 'tomb-of-the-mutilated', title: 'Tomb of the Mutilated', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], releaseDate: '1992'),
  Album(id: 'bloodthirst', title: 'Bloodthirst', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], releaseDate: '1999'),
  Album(id: 'reign-in-blood', title: 'Reign in Blood', bandIds: ['slayer'], bandNames: ['Slayer'], releaseDate: '1986'),
  Album(id: 'seasons-in-the-abyss', title: 'Seasons in the Abyss', bandIds: ['slayer'], bandNames: ['Slayer'], releaseDate: '1990'),
  Album(id: 'ten', title: 'Ten', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], releaseDate: '1991'),
  Album(id: 'vs', title: 'Vs.', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], releaseDate: '1993'),
  Album(id: 'foxtrot', title: 'Foxtrot', bandIds: ['genesis'], bandNames: ['Genesis'], releaseDate: '1972'),
  Album(id: 'selling-england-by-the-pound', title: 'Selling England by the Pound', bandIds: ['genesis'], bandNames: ['Genesis'], releaseDate: '1973'),
  Album(id: 'music-for-the-jilted-generation', title: 'Music for the Jilted Generation', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], releaseDate: '1994'),
  Album(id: 'the-fat-of-the-land', title: 'The Fat of the Land', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], releaseDate: '1997'),
  Album(id: 'pretty-hate-machine', title: 'Pretty Hate Machine', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], releaseDate: '1989'),
  Album(id: 'the-downward-spiral', title: 'The Downward Spiral', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], releaseDate: '1994'),
  Album(id: 'altars-of-madness', title: 'Altars of Madness', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], releaseDate: '1989'),
  Album(id: 'covenant', title: 'Covenant', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], releaseDate: '1993'),
];
