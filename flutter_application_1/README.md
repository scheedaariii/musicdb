# Info

Author: Daniel Hafner
Schule: Teko Olten
Klasse: O-WWI-23-T-b

# AI Nutzung

Reiner Text Content wurde per AI generiert und abgefüllt. Ebenso sind einige Code Stellen AI generiert worden. Die stellen sind entsprechend markiert.

# Dokumentation

1. Welche Daten werden in Firebase gespeichert?

Sechs Firestore-Sammlungen, jede über IDs miteinander verknüpft (keine Namens-Kopien):

bands: title, descriptionText, genreIds, origin, founded
musicians: firstName, lastName, dateOfBirth, descriptionText, bandIds, roleIds
albums: title, bandIds, genreIds, releaseDate, descriptionText
songs: title, durationSeconds, albumIds, bandIds, releaseDate, descriptionText
genres: title, descriptionText
roles: title, descriptionText

2. Wo sind Create, Read, Update, Delete umgesetzt?
Create: add_data_screen.dart (Formular über den Plus-Button) → ruft repo.addBand()/addMusician()/usw. in database_repository.dart auf, die jeweils eine neue Firestore-ID vergeben und das Dokument schreiben.
Read: DatabaseRepository.load() holt beim App-Start alle sechs Sammlungen; database_category_screen.dart zeigt die Listen, item_detail_screen.dart die Detailansicht.
Update: item_detail_screen.dart im Bearbeitungsmodus (Stift-Button) → repo.updateBand()/updateMusician()/usw.
Delete: derselbe Screen, Löschen-Button mit Bestätigungsdialog → repo.deleteBand()/usw., die auch alle Verknüpfungen bei anderen Einträgen bereinigen (z.B. eine gelöschte Band wird auch aus den Musikern/Alben/Songs entfernt, die auf sie verweisen).

3. Was wurde gegenüber Teil 1 weiterentwickelt?

Das Datenschema wurde deutlich erweitert. Bands ist nun nur noch eine Kategorie die Teil der ganzen Datenbank ist und wird nicht mehr direkt ausgewählt über "Database" im Footer. Dieser Button zielt nun auf die Kategory übersicht wo Bands gemeinsam mit anderen Kategorien angezeigt wird.
Das Projekt wurde auf Firestore angelegt und damit verknüpft. Ein Grossteil der Daten wird nun von Firestore geladen und dahin gesichert.
Alle CRUD Funktionen wurden implementiert. Daten können angelegt, gelöscht und bearbeitet werden. Die wurden nahtlos in die App eingefügt.
Dateneingaben werden vor dem speichern validiert.
Eine Filter Funktion wurde eingebaut und grössere Datenbestände rasch zu durchforsten.
Diverse Widgets und auch Desing Elemente die mehrfach verwendet wurden sind identifiziert und zusammengeführt worden.
Der Drawer ist aktuell absichtlich nicht in den Detailseiten drin. Er bringt dort aktuell keinen Mehrwert.

4. Sinnvolle nächste Erweiterung für Teil 3

Firebase Authentication implementieren. Firestore.rules steht aktuell komplett offen weil es noch keine Nutzeranmeldung gibt. Daraus folgt das umbauen der statischen Profilseite in ein Interaktives Element mit echten Nutzen.
Ein Indikator der anzeigt wen man sich im "Offline-Modus" befindet.
Das Datumsformat ist akuell Jahr/Monat/Tag -> zu Tag/Monat/Jahr ändern
Platzhalter Texte vollständig ersetztn.
Bug beheben: Im Bearbeitungsmodus nur der Speichern-Button, sobald sich etwas geändert hat. Ausserhalb davon Bearbeiten und Löschen nebeneinander. Hier gibt es noch einen Bug dass das Anklicken eines Felder bereits als Änderung gewertet wird und der speicher Button somit aktiv wird.

Finale Abgabe

Userprofil: Aktuell bewusst auf einen Bildupload verzichtet (z.b. mit der package image_picker), da kein Berühurngspunkt zwischen den Benutzern besteht welcher ein Bild Sinnvoll machen würde. Ein Automatisch generierter Platzhalter ist jedoch bereits vorhanden sollte später eine share Funktion dazukommen.
Feedback zur Grösse database_repository konnte nicht wirklich berücksichtigt werden. Siehe Kommentar im betroffen File selbst.
Die Statistiken im userprofil dienen als Beispiel für mögliche weitere Statisktiken. In der Zukunft könnt eman hier noch ein Favoriten Funktion einbauen.
Abgeleitet aus dem Testmanagement wurde ein Bug gefixed der es erlaubte Bands doppelt anzulegen. Bug-01 in add_data_screen.dart kommentiert.
Die zeigt Funktionen die einen Mailversand beinhalten. Diese funktionieren aktuell nicht komplett da keine Mail Infra hinterlegt ist (pw reset, pw änderung).
Ich sehe folgende Schritte als die nächsten logischen Erweiterungen:
- Bild Upload für die Kategorien und User Profilseite
- Mitglieder Historie für Bands
- Sharen von Daten zwischen Benutzern
    - Friendsliste
    - Datashareing
    - chat?

# Fragen zur Abgabe (Teil 4)

1. Wo sind Authentication und CRUD umgesetzt?

Authentication: lib/features/auth/ – data/auth_repository.dart kapselt Firebase Auth (Registrieren, Anmelden, Abmelden, Passwort zurücksetzen, E-Mail/Username ändern), data/auth_errors.dart übersetzt alle Firebase-Fehlercodes in verständliche deutsche Meldungen. Die UI liegt in presentation/login_screen.dart und presentation/register_screen.dart. Eingebunden wird das Ganze über ein Auth-Gate in lib/app/app.dart, das per StreamBuilder auf den Login-Status hört und automatisch zwischen Login-Screen und der eigentlichen App wechselt.

CRUD: lib/features/database/data/database_repository.dart – sämtliche Firestore-Zugriffe für die sechs Kategorien, inklusive atomarer Kaskaden-Updates/-Löschungen bei Verknüpfungen (WriteBatch). Create läuft über presentation/add_data_screen.dart, Read/Update/Delete über presentation/item_detail_screen.dart. Seit der Authentifizierung hat jede Person ihre eigene, private Datenbank (users/{uid}/{kategorie}), zusätzlich abgesichert über firestore.rules.

2. Welches zusätzliche Flutter-Package wurde eingesetzt und wofür?

shared_preferences – speichert dauerhaft auf dem Gerät, ob der Welcome-/Onboarding-Screen schon gesehen wurde (lib/features/onboarding/data/onboarding_repository.dart), damit er nur beim allerersten Start der App erscheint.

3. Welche wesentlichen Fehler bzw. Rückmeldungen aus Teil 1 und Teil 2 wurden bereinigt?

- Keine Schreibsperren beim Speichern: Buttons werden jetzt während eines laufenden Firestore-Schreibvorgangs gesperrt, damit ein zweiter Klick keinen doppelten Eintrag erzeugt.
- Änderungen wurden lokal übernommen, bevor Firebase den Schreibvorgang bestätigt hatte (kein Rollback bei Fehlern): Alle add-/update-/delete-Methoden warten jetzt den Firestore-Erfolg ab, bevor die lokale Liste angepasst wird.
- Verknüpfte Updates (z. B. beim Löschen einer Band bei allen ihren Musikern/Alben/Songs) waren nicht atomar: Jetzt über WriteBatch gebündelt und gemeinsam committet.
- UI-Fehlermeldungen wurden direkt aus dem Repository ausgelöst: Das Repository legt Fehler nur noch ab (lastError), die Anzeige übernimmt zentral die UI-Schicht in app.dart.
- Die Datenbank war ursprünglich für alle Nutzer gemeinsam: Seit der Authentifizierung hat jede Person ihre eigene, private Datenbank.

4. Welche Bereiche der App wurden besonders refaktoriert bzw. verbessert?

Die gesamte Schreiblogik in database_repository.dart (Atomarität, Fehlerbehandlung, Laden pro Benutzer statt gemeinsam), das Profil (echte Statistiken aus den Daten statt doppelter Zähler zur Datenbank-Übersicht, App-Icon statt Initialen, "Mitglied seit"), sowie eigenes Launcher-Icon, Splash-Screen, Impressum, Welcome-Screen. Zuletzt wurde beim Ausbau des Testmanagements ein Fehler bei der Eindeutigkeitsprüfung neuer Bands gefunden: Sie verglich zusätzlich Gründungsjahr und Genre statt wie beim Bearbeiten nur den Namen, wodurch zwei Bands mit demselben Namen angelegt werden konnten (Bug-01, siehe Kommentar in add_data_screen.dart). Behoben und per Re-Test sowie Regressionstests bestätigt.

