// musician_mock_data.dart
// Enthält die Startdaten für Musiker.
// Über bandIds sind die Musiker mit ihren Bands verknüpft.

import '../domain/musician.dart';

const List<Musician> seedMusicians = [
  Musician(id: 'james-hetfield', firstName: 'James', lastName: 'Hetfield', bandIds: ['metallica', 'nirvana'], bandNames: ['Metallica', 'Nirvana'], roles: ['Gesang', 'Gitarre']),
  Musician(id: 'lars-ulrich', firstName: 'Lars', lastName: 'Ulrich', bandIds: ['metallica'], bandNames: ['Metallica'], roles: ['Schlagzeug']),
  Musician(id: 'kirk-hammett', firstName: 'Kirk', lastName: 'Hammett', bandIds: ['metallica'], bandNames: ['Metallica'], roles: ['Leadgitarre']),
  Musician(id: 'david-gilmour', firstName: 'David', lastName: 'Gilmour', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], roles: ['Gitarre', 'Gesang']),
  Musician(id: 'roger-waters', firstName: 'Roger', lastName: 'Waters', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], roles: ['Bass', 'Gesang']),
  Musician(id: 'nick-mason', firstName: 'Nick', lastName: 'Mason', bandIds: ['pink-floyd'], bandNames: ['Pink Floyd'], roles: ['Schlagzeug']),
  Musician(id: 'thomas-bangalter', firstName: 'Thomas', lastName: 'Bangalter', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], roles: ['Produktion', 'Synthesizer']),
  Musician(id: 'guy-manuel-de-homem-christo', firstName: 'Guy-Manuel', lastName: 'de Homem-Christo', bandIds: ['daft-punk'], bandNames: ['Daft Punk'], roles: ['Produktion', 'Synthesizer']),
  Musician(id: 'kurt-cobain', firstName: 'Kurt', lastName: 'Cobain', bandIds: ['nirvana'], bandNames: ['Nirvana'], roles: ['Gesang', 'Gitarre']),
  Musician(id: 'krist-novoselic', firstName: 'Krist', lastName: 'Novoselic', bandIds: ['nirvana'], bandNames: ['Nirvana'], roles: ['Bass']),
  Musician(id: 'dave-grohl', firstName: 'Dave', lastName: 'Grohl', bandIds: ['nirvana'], bandNames: ['Nirvana'], roles: ['Schlagzeug']),
  Musician(id: 'till-lindemann', firstName: 'Till', lastName: 'Lindemann', bandIds: ['rammstein'], bandNames: ['Rammstein'], roles: ['Gesang']),
  Musician(id: 'richard-z-kruspe', firstName: 'Richard', lastName: 'Z. Kruspe', bandIds: ['rammstein'], bandNames: ['Rammstein'], roles: ['Leadgitarre']),
  Musician(id: 'flake-lorenz', firstName: 'Flake', lastName: 'Lorenz', bandIds: ['rammstein'], bandNames: ['Rammstein'], roles: ['Keyboard']),
  Musician(id: 'george-fisher', firstName: 'George', lastName: 'Fisher', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], roles: ['Gesang']),
  Musician(id: 'alex-webster', firstName: 'Alex', lastName: 'Webster', bandIds: ['cannibal-corpse'], bandNames: ['Cannibal Corpse'], roles: ['Bass']),
  Musician(id: 'tom-araya', firstName: 'Tom', lastName: 'Araya', bandIds: ['slayer'], bandNames: ['Slayer'], roles: ['Gesang', 'Bass']),
  Musician(id: 'kerry-king', firstName: 'Kerry', lastName: 'King', bandIds: ['slayer'], bandNames: ['Slayer'], roles: ['Gitarre']),
  Musician(id: 'eddie-vedder', firstName: 'Eddie', lastName: 'Vedder', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], roles: ['Gesang', 'Gitarre']),
  Musician(id: 'stone-gossard', firstName: 'Stone', lastName: 'Gossard', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], roles: ['Gitarre']),
  Musician(id: 'mike-mccready', firstName: 'Mike', lastName: 'McCready', bandIds: ['pearl-jam'], bandNames: ['Pearl Jam'], roles: ['Leadgitarre']),
  Musician(id: 'peter-gabriel', firstName: 'Peter', lastName: 'Gabriel', bandIds: ['genesis'], bandNames: ['Genesis'], roles: ['Gesang', 'Flöte']),
  Musician(id: 'phil-collins', firstName: 'Phil', lastName: 'Collins', bandIds: ['genesis'], bandNames: ['Genesis'], roles: ['Schlagzeug', 'Gesang']),
  Musician(id: 'tony-banks', firstName: 'Tony', lastName: 'Banks', bandIds: ['genesis'], bandNames: ['Genesis'], roles: ['Keyboard']),
  Musician(id: 'liam-howlett', firstName: 'Liam', lastName: 'Howlett', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], roles: ['Produktion', 'Keyboard']),
  Musician(id: 'keith-flint', firstName: 'Keith', lastName: 'Flint', bandIds: ['the-prodigy'], bandNames: ['The Prodigy'], roles: ['Gesang']),
  Musician(id: 'trent-reznor', firstName: 'Trent', lastName: 'Reznor', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], roles: ['Gesang', 'Instrumente']),
  Musician(id: 'atticus-ross', firstName: 'Atticus', lastName: 'Ross', bandIds: ['nine-inch-nails'], bandNames: ['Nine Inch Nails'], roles: ['Produktion', 'Synthesizer']),
  Musician(id: 'trey-azagthoth', firstName: 'Trey', lastName: 'Azagthoth', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], roles: ['Leadgitarre']),
  Musician(id: 'steve-tucker', firstName: 'Steve', lastName: 'Tucker', bandIds: ['morbid-angel'], bandNames: ['Morbid Angel'], roles: ['Gesang', 'Bass']),
];
