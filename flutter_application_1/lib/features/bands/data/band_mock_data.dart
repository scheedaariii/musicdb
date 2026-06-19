// Enthält hardcodierte Beispieldaten für Bands
// Die Daten wurden per AI in die Struktur abgefüllt

import '../domain/band.dart';

final List<Band> mockBands = const [
  Band(
    title: 'Metallica',
    description:
        'Metallica ist eine US-amerikanische Heavy-Metal-Band, die 1981 in Los Angeles gegründet wurde. '
        'Sie gehören zu den erfolgreichsten und einflussreichsten Bands der Musikgeschichte und haben '
        'über 125 Millionen Alben weltweit verkauft. Bekannte Alben sind "Master of Puppets" und "The Black Album".',
    genre: 'Heavy Metal / Thrash Metal',
    origin: 'Los Angeles, USA',
    founded: '1981',
  ),
  Band(
    title: 'Pink Floyd',
    description:
        'Pink Floyd ist eine britische Rockband, die 1965 in London gegründet wurde. '
        'Sie sind bekannt für ihre psychedelischen und progressiven Klanglandschaften sowie '
        'ihre aufwändigen Live-Shows. Alben wie "The Dark Side of the Moon" und "The Wall" '
        'gehören zu den meistverkauften Alben aller Zeiten.',
    genre: 'Progressive Rock / Psychedelic Rock',
    origin: 'London, UK',
    founded: '1965',
  ),
  Band(
    title: 'Daft Punk',
    description:
        'Daft Punk war ein französisches Elektronik-Musik-Duo, bestehend aus Thomas Bangalter '
        'und Guy-Manuel de Homem-Christo. Sie wurden 1993 in Paris gegründet und prägten mit '
        'Alben wie "Homework" und "Random Access Memories" die elektronische Musikszene massgeblich. '
        'Das Duo löste sich 2021 auf.',
    genre: 'Electronic / House / Dance',
    origin: 'Paris, Frankreich',
    founded: '1993',
  ),
  Band(
    title: 'Nirvana',
    description:
        'Nirvana war eine US-amerikanische Grunge-Band aus Aberdeen, Washington. '
        'Sie wurden 1987 von Kurt Cobain und Krist Novoselic gegründet und revolutionierten '
        'mit ihrem Album "Nevermind" die Musikwelt. Der Grunge-Sound und die rohe Energie '
        'der Band beeinflussten eine ganze Generation von Musikern.',
    genre: 'Grunge / Alternative Rock',
    origin: 'Aberdeen, USA',
    founded: '1987',
  ),

  Band(
    title: 'Rammstein',
    description:
        'Rammstein ist eine deutsche Neue Deutsche Härte Band, die 1994 in Berlin gegründet wurde. '
        'Bekannt für ihre explosive Live-Show und ihren charakteristischen Sound, haben sie sich '
        'zu einer der bekanntesten deutschen Bands weltweit entwickelt. Ihr Debütalbum "Herzeleid" '
        'erschien 1995.',
    genre: 'Neue Deutsche Härte / Industrial Metal',
    origin: 'Berlin, Deutschland',
    founded: '1994',
  ),

  Band(
    title: 'Cannibal Corpse',
    description:
        'Cannibal Corpse ist eine US-amerikanische Death-Metal-Band, die 1988 in Buffalo, New York gegründet wurde. '
        'Sie gelten als eine der einflussreichsten und meistverkauften Death-Metal-Bands aller Zeiten. '
        'Mit über 2 Millionen verkauften Alben haben sie das Genre massgeblich geprägt. '
        'Bekannte Alben sind "Tomb of the Mutilated" und "Bloodthirst".',
    genre: 'Death Metal / Brutal Death Metal',
    origin: 'Buffalo, USA',
    founded: '1988',
  ),
];
