# Shopper

Projekt stworzony na konkurs elektronhack 2023.

## Jaki problem rozwiązuje nasza aplikacja?

Aplikacja Shopper to znacznie więcej niż zwykła lista zakupów! Shopper zawiera też przepisy na pyszne dania ze wszystkimi 
potrzebnymi informacjami do ich przyrządzenia. Bezpośrednio z przepisu można utworzyć listę zakupów co zaoszczędza czas. Zaletą tak stworzonej listy zakupów jest wstrzymanie się od kupowania nie potrzebnych produktów w sklepie.

## Dodatkowe funkcjonalności

W aplikacji shopper można też zobaczyć mapę ze sklepami w pobliżu. Dla większości sklepów dostępne są też takie dane jak: numer telefonu, strona internetowa i adres. Inne z dodatkowych funkcji aplikacji to obsługa trybu ciemnego.


## Uruchamianie aplikacji

### Sposób 1 - gotowy plik .apk

W zakładce "Releases" do pobrania dostępny jest plik shopper.apk. Wystarczy go zainstalować nha urządzeniu z systemem android (może być konieczne zezwolenie na instalacje aplikacji z nieznanych źródeł).

### Sposób 2 - ręczna kompilacja pliku .apk

Jeśli nie chcesz korzystać ze zbudowanego przez nas pliku, możesz go zbudować samodzielnie. By to zrobić:
1. Zainstaluj środowisko deweloperskie [Flutter](https://docs.flutter.dev/get-started/install). Najprawdopodobniej będzie też konieczna instalacja [Android Studio](https://developer.android.com/studio).
2. Pobierz kod źródłowy aplikacji shopper. Możesz użyć komendy "git clone" lub pobrać kod z zakładki "Releases" i wypakować pazkę .zip
3. Otwórz terminal w głównym folderze kodu źródłowego aplikacji shopper i wykonaj komendę "flutter build apk" (można też zbudować aplikację na inne platformy, ale należy pamiętać, że aplikacja została stworzona z myślą o systemie android i w innych środowiskach może nie działać lub działać niepoprawnie).
4. Po ukończeniu kompilowania w konsoli wyświetli się ścieżka do nowo stworzonego pliku .apk. Zainstaluj go na urządzeniu z systemem android (może być konieczne zezwolenie na instalacje aplikacji z nieznanych źródeł).
