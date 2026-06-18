// Enthält hardcodierte Beispieldaten für Bands. Nach der definition des Datenschemas wurden die Daten selbst via AI generiert
// Auf dieser Stufe des Projekts werden die Daten direkt im Band Sektor angezeigt/gespeichert. Im Verlaufe des Projekts werden die Daten in eigene Kategorien aufgeteilt.

import '../domain/band.dart';

// Liste mit Beispiel-Bands für verschiedene Genres
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
    title: 'The Beatles',
    description:
        'The Beatles sind eine britische Rockband aus Liverpool, die 1960 gegründet wurde. '
        'Bestehend aus John Lennon, Paul McCartney, George Harrison und Ringo Starr, '
        'gelten sie als die einflussreichste Band der Popgeschichte. Ihre Musik prägte '
        'die 1960er Jahre und hat bis heute eine weltweite Wirkung.',
    genre: 'Rock / Pop',
    origin: 'Liverpool, UK',
    founded: '1960',
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
];
