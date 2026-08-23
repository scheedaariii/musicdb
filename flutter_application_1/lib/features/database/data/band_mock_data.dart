// band_mock_data.dart
// Enthält die Startdaten für Bands.
// Neue Bands werden zur Laufzeit über das Repository ergänzt.

import '../domain/band.dart';

const List<Band> seedBands = [
  Band(
    id: 'metallica',
    title: 'Metallica',
    descriptionText:
        'Metallica ist eine US-amerikanische Heavy-Metal-Band, die 1981 in Los Angeles gegründet wurde. '
        'Sie gehören zu den erfolgreichsten und einflussreichsten Bands der Musikgeschichte und haben '
        'über 125 Millionen Alben weltweit verkauft. Bekannte Alben sind "Master of Puppets" und "The Black Album".',
    genres: ['Heavy Metal', 'Thrash Metal'],
    origin: 'Los Angeles, USA',
    founded: '1981',
  ),
  Band(
    id: 'pink-floyd',
    title: 'Pink Floyd',
    descriptionText:
        'Pink Floyd ist eine britische Rockband, die 1965 in London gegründet wurde. '
        'Sie sind bekannt für ihre psychedelischen und progressiven Klanglandschaften sowie '
        'ihre aufwändigen Live-Shows. Alben wie "The Dark Side of the Moon" und "The Wall" '
        'gehören zu den meistverkauften Alben aller Zeiten.',
    genres: ['Progressive Rock', 'Psychedelic Rock'],
    origin: 'London, UK',
    founded: '1965',
  ),
  Band(
    id: 'daft-punk',
    title: 'Daft Punk',
    descriptionText:
        'Daft Punk war ein französisches Elektronik-Musik-Duo, bestehend aus Thomas Bangalter '
        'und Guy-Manuel de Homem-Christo. Sie wurden 1993 in Paris gegründet und prägten mit '
        'Alben wie "Homework" und "Random Access Memories" die elektronische Musikszene massgeblich. '
        'Das Duo löste sich 2021 auf.',
    genres: ['Electronic', 'House', 'Dance'],
    origin: 'Paris, Frankreich',
    founded: '1993',
  ),
  Band(
    id: 'nirvana',
    title: 'Nirvana',
    descriptionText:
        'Nirvana war eine US-amerikanische Grunge-Band aus Aberdeen, Washington. '
        'Sie wurden 1987 von Kurt Cobain und Krist Novoselic gegründet und revolutionierten '
        'mit ihrem Album "Nevermind" die Musikwelt. Der Grunge-Sound und die rohe Energie '
        'der Band beeinflussten eine ganze Generation von Musikern.',
    genres: ['Grunge', 'Alternative Rock'],
    origin: 'Aberdeen, USA',
    founded: '1987',
  ),
  Band(
    id: 'rammstein',
    title: 'Rammstein',
    descriptionText:
        'Rammstein ist eine deutsche Neue Deutsche Härte Band, die 1994 in Berlin gegründet wurde. '
        'Bekannt für ihre explosive Live-Show und ihren charakteristischen Sound, haben sie sich '
        'zu einer der bekanntesten deutschen Bands weltweit entwickelt. Ihr Debütalbum "Herzeleid" '
        'erschien 1995.',
    genres: ['Neue Deutsche Härte', 'Industrial Metal'],
    origin: 'Berlin, Deutschland',
    founded: '1994',
  ),
  Band(
    id: 'cannibal-corpse',
    title: 'Cannibal Corpse',
    descriptionText:
        'Cannibal Corpse ist eine US-amerikanische Death-Metal-Band, die 1988 in Buffalo, New York gegründet wurde. '
        'Sie gelten als eine der einflussreichsten und meistverkauften Death-Metal-Bands aller Zeiten. '
        'Mit über 2 Millionen verkauften Alben haben sie das Genre massgeblich geprägt. '
        'Bekannte Alben sind "Tomb of the Mutilated" und "Bloodthirst".',
    genres: ['Death Metal', 'Brutal Death Metal'],
    origin: 'Buffalo, USA',
    founded: '1988',
  ),
  Band(
    id: 'slayer',
    title: 'Slayer',
    descriptionText:
        'Slayer war eine US-amerikanische Thrash-Metal-Band, die 1981 in Huntington Park, '
        'Kalifornien gegründet wurde. Zusammen mit Metallica, Megadeth und Anthrax zählte '
        'die Band zu den "Big Four" des Thrash Metal. Ihr Album "Reign in Blood" von 1986 '
        'gilt als eines der einflussreichsten Metal-Alben überhaupt.',
    genres: ['Thrash Metal', 'Heavy Metal'],
    origin: 'Huntington Park, USA',
    founded: '1981',
  ),
  Band(
    id: 'pearl-jam',
    title: 'Pearl Jam',
    descriptionText:
        'Pearl Jam ist eine US-amerikanische Grunge-Band aus Seattle, die 1990 gegründet wurde. '
        'Ihr Debütalbum "Ten" machte die Band zu einem der wichtigsten Vertreter des '
        'Seattle-Sounds. Zusammen mit Nirvana prägten sie die Grunge-Bewegung der frühen '
        'neunziger Jahre.',
    genres: ['Grunge', 'Alternative Rock'],
    origin: 'Seattle, USA',
    founded: '1990',
  ),
  Band(
    id: 'genesis',
    title: 'Genesis',
    descriptionText:
        'Genesis ist eine britische Rockband, die 1967 in Godalming gegründet wurde. '
        'In den siebziger Jahren zählte die Band mit Alben wie "Selling England by the Pound" '
        'zu den bedeutendsten Vertretern des Progressive Rock, bevor sie sich später einem '
        'poporientierten Sound zuwandte.',
    genres: ['Progressive Rock', 'Art Rock'],
    origin: 'Godalming, UK',
    founded: '1967',
  ),
  Band(
    id: 'the-prodigy',
    title: 'The Prodigy',
    descriptionText:
        'The Prodigy ist eine britische Electronic-Band, die 1990 in Braintree gegründet wurde. '
        'Mit dem Album "The Fat of the Land" verbanden sie elektronische Musik mit Punk- und '
        'Rock-Elementen und erreichten damit ein weltweites Publikum.',
    genres: ['Electronic', 'Big Beat', 'Dance'],
    origin: 'Braintree, UK',
    founded: '1990',
  ),
  Band(
    id: 'nine-inch-nails',
    title: 'Nine Inch Nails',
    descriptionText:
        'Nine Inch Nails ist ein US-amerikanisches Industrial-Projekt von Trent Reznor, '
        'das 1988 in Cleveland gegründet wurde. Mit Alben wie "The Downward Spiral" prägte '
        'Reznor den Industrial-Sound der neunziger Jahre massgeblich.',
    genres: ['Industrial Metal', 'Industrial Rock'],
    origin: 'Cleveland, USA',
    founded: '1988',
  ),
  Band(
    id: 'morbid-angel',
    title: 'Morbid Angel',
    descriptionText:
        'Morbid Angel ist eine US-amerikanische Death-Metal-Band, die 1983 in Tampa, Florida '
        'gegründet wurde. Ihr Debütalbum "Altars of Madness" gilt als Meilenstein des Genres '
        'und machte die Band neben Cannibal Corpse zu einem der Aushängeschilder der '
        'Death-Metal-Szene Floridas.',
    genres: ['Death Metal', 'Technical Death Metal'],
    origin: 'Tampa, USA',
    founded: '1983',
  ),
];
